# Ocean of PDF EPUB fixer

## Purpose

This repository contains a script to fix the EPUB files loaded from the
[Ocean of PDF](https://oceanofpdf.com/) website.

The main issue with the books is that the text is too dense,
and e-readers, such as Kobo, ignore line spacing user setting.

## Usage

Put the script on your PATH and run it as:

```shell
fix-oceanofpdf.sh [directory]
```

The directory is optional and defaults to the current directory.
It can be absolute or relative to the current directory.

The script creates new EPUB files in the 'fixed' subdirectory of the original
directory.
