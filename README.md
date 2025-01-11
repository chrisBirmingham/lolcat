# Lolcat

An imperfect implementation of the [lolcat](https://github.com/busyloop/lolcat) 
program written in C. The original version was written in V and can be found
in the `original-main` branch.

## Requirements

* (gnu) make
* A version of gcc or clang that supports c11
* A (*)nix based operating system. 

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

* The truecolor colour palette is currently the only supported colour palette. 
* The program doesn't check to see if the terminal supports truecolor so if you're using something like MacOS's terminal, the output will look wrong.

## Inspiration

* Jim Bumgardner for his excellent tutorial on making annoying rainbows [here](https://krazydad.com/tutorials/makecolors.php)
* And of cource [lolcat](https://github.com/busyloop/lolcat)

