# Lolcat

An imperfect implementation of the [lolcat](https://github.com/busyloop/lolcat) 
program written in C. The original version was written in V and can be found
in the `original-main` branch.

## Requirements

* (gnu) make
* A version of gcc or clang that supports c11
* A (*)nix based operating system. 
* glibc >= 2.36 or libbsd on non bsd systems for arc4random support

## Installation

To install lolcat you can run the following commands

```sh
git clone https://github.com/chrisBirmingham/lolcat
cd lolcat
make
[sudo] make install
```

By default, the makefile installs to /usr/local/bin. This can be overridden
with the `PREFIX` variable

```sh
make install PREFIX=~/.local
```

## Limitations

* The truecolor and rgb256 colour palettes are the only supported colour palettes. Truecolor is the default colour patlette if it cannot detect your supported colour pallet via `COLORTERM` or `TERM`
* If you have `NO_COLOR` set or `TERM` is set to dumb, lolcat will exit with `EXIT_FAILURE` instead of printing plain text. Use `cat` if you don't want coloured text.

## Inspiration/Attributions

* Jim Bumgardner for his excellent tutorial on making annoying rainbows [here](https://krazydad.com/tutorials/makecolors.php)
* The [Ruby Paint Gem](https://github.com/janlelis/paint) for their truecolor to rgb256 conversion logic
* And of cource [lolcat](https://github.com/busyloop/lolcat)
