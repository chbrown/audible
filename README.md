# Audible

Audio extraction and chapter splitting from Audible audiobooks.

Like [`AAXtoMP3`](https://github.com/KrumpetPirate/AAXtoMP3) but without the transcoding.


#### Prerequisites

* [`ffmpeg`](https://www.ffmpeg.org/)

#### Installation

```sh
curl -L https://git.io/audible-sh > /usr/local/bin/audible
chmod +x /usr/local/bin/audible
```

<!-- Development:
```sh
ln -s "$PWD/audible.sh" /usr/local/bin/audible
``` -->

#### Instructions

```sh
audible --help
```
> Usage: audible --activation-bytes a1b2c3d4 [book1.aax ...] [-h|--help] [-v|--verbose]
>
> Arguments:\
> &nbsp; -a, --activation-bytes HEXACODE&nbsp; Audible activation bytes (8 hexadecimal characters)

#### Usage

```sh
audible -a a1b2c3d4 SomeBook.aax
```

This will create a new folder like <code><i>Author</i> - <i>Title</i></code> in the current directory,
then write a series of <code>Chapter <i>N</i>.m4b</code> files inside that folder.
In a typical workflow, you'll `cd` to wherever you store your audiobooks, then call the script using the full `.aax` filepath.

Obviously, you'll need to replace the `a1b2c3d4` with your personal Audible "activation bytes";
to retrieve these...
* ...from your Audible account (easy), use <https://github.com/inAudible-NG/audible-activator>
* ...from a lone `.aax` file (harder), use <https://github.com/inAudible-NG/tables>


## License

Copyright © 2018 Christopher Brown.
[MIT Licensed](https://chbrown.github.io/licenses/MIT/#2018).
