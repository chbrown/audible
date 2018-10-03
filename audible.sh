#!/usr/bin/env bash

set -e # exit immediately on first error

usage() {
  >&2 cat <<HELP
Usage: $(basename "$0") --activation-bytes a1b2c3d4 [book1.aax ...] [-h|--help] [-v|--verbose]

Arguments:
  -a, --activation-bytes HEXACODE  Audible activation bytes (8 hexadecimal characters)
HELP
}

AAX_FILES=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--verbose)
      set -x
      >&2 printf 'Entering debug (verbose) mode\n'
      ;;
    -a|--activation-bytes)
      shift
      ACTIVATION_BYTES=$1
      ;;
    *.aax)
      AAX_FILES+=("$1")
      ;;
    *)
      >&2 printf 'Unrecognized argument: %s\n' "$1"
      exit 1
      ;;
  esac
  shift
done

if [[ -z ${ACTIVATION_BYTES+missing} ]]; then
  >&2 printf 'The --activation-bytes argument is required.\n'
  usage
  exit 1
fi

if [[ ${#AAX_FILES[@]} -eq 0 ]]; then
  usage
  >&2 printf '\nYou must supply at least one file (the .aax extension is required).\n'
  exit 1
fi

for AAX in "${AAX_FILES[@]}"; do
  # prepare list of arguments shared between all calls to ffprobe/ffmpeg
  FFOPTS=(-hide_banner -loglevel error -activation_bytes "$ACTIVATION_BYTES" -i "$AAX")
  # read artist and album metadata from format tags (p=0 omits section name)
  IFS=, read -r ARTIST ALBUM < <(ffprobe "${FFOPTS[@]}" -print_format csv=p=0 -show_entries format_tags=artist,album)
  # write all output to (new) directory within current directory
  OUTDIR="$ARTIST - $ALBUM"
  >&2 printf 'Creating directory "%s"\n' "$OUTDIR"
  mkdir -p "$OUTDIR"

  # get total chapter count (short form of more specific input to while loop)
  NCHAPTERS=$(ffprobe "${FFOPTS[@]}" -print_format csv -show_chapters | wc -l)
  >&2 printf 'Extracting %d chapters from "%s"\n' "$NCHAPTERS" "$AAX"
  # loop over each chapter, extracting directly from original file
  while IFS=, read -r ID START_TIME END_TIME TITLE_TAG; do
    OUTFILE=$TITLE_TAG.m4b
    >&2 printf '  Cutting %9.3f-%9.3f as "%s"\n' "$START_TIME" "$END_TIME" "$OUTFILE"
    # 1. slice partitions as specified by chapter metadata (-ss, -to)
    # 2. copy both audio and video to output (-c copy), but drop data stream (-dn)
    # 3. drop chapter metadata (-map_chapters -1)
    # 4. overwrite track/title metadata with per-chapter values (-metadata)
    ffmpeg -nostdin "${FFOPTS[@]}" \
      -ss "$START_TIME" -to "$END_TIME" \
      -c copy -dn \
      -map_chapters -1 \
      -metadata title="$TITLE_TAG" -metadata track="$((ID + 1))/$NCHAPTERS" \
      "$OUTDIR/$OUTFILE"
  done < <(ffprobe "${FFOPTS[@]}" -print_format csv=p=0 -show_entries chapter=id,start_time,end_time:chapter_tags=title)
done
