# Dumpling

A tiny, simple CLI tool that embeds files in Crystal code.

## Hmm?

Ever had a file you wanted to access in your program without having to read it from the disk? Or resource files your library depends on that you don't want to have to finagle people into loading themselves?

Dumpling dumps file data through a couple of layers of processing to produce a Crystal file which exposes methods to unpack the original data. That way, you can embed fonts, icons, or whatever else you need to in your library code itself instead of in regular resource files.

## With great power, etc.

It's public domain, but I can still ask you to be smart and non-evil with it.

Also, you probably don't want to get super crazy with the size of the files you're encoding, because the data is decoded and decompressed at runtime. The original use case was for bitmap fonts for my WIP UI library to load as part of the default skin--a few dozen kilobytes at most. Users probably don't want your library to decompress and decode a 50-megabyte file when the program starts up.

## Usage

It's a command line utility, so after you've built it, just call:

```
path/to/dumpling in_file out_file -m CrystalModuleName -n "Note at top of code"
```

You can also pass `--help` to get a list of all options.

The in file will be processed and converted into Crystal code (or raw Base64 with `-r`, although I'm not sure whether that's useful for anyone), which can then be imported into your program at compile time:
```
require "./packed_font_file.cr"

def load
	font_data = PackedFontFileModuleName.unpack_bytes
end
```
The name of the encoded module defaults to a cleaned form of the input file's name suffixed by `Data` (`icon-file-128.png` turns into `module IconFile128Data`), but you can also send a custom name to Dumpling using the `-m MODULE`/`--module=MODULE` option:
```
path/to/dumpling icon-file-128.png icon_data.cr -m EmbeddedData::Icon128
```

## Building

```
crystal build --release src/dumpling.cr
```

## How is data stored?

Base64 encoding of Gzip deflation of original contents.

## Examples?

In `resources`, there's a unicode copy of the [Gohu font](https://font.gohu.org) and the embeddable Crystal code generated with
```
./dumpling resources/gohu_14_unicode.bdf resources/gohu_14.cr -n "Gohu font from https://font.gohu.org"
```

## But the name?

It dumps stuff. It's small. I like jiaozi.
