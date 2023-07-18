# Lolcat

An imperfect implementation of the [lolcat](https://github.com/busyloop/lolcat) program in the [V Programming Language](https://vlang.io/)

## Installation

```sh
git clone https://github.com/chrisBirmingham/v-lolcat
cd v-lolcat
make
sudo make install
```

## Key differences to cat

* Providing `-` as the first commandline argument is not supported. The V cli module interprets `-` as a start of a commandline flag and will report that no such flag exists. Providing `-` as part of a subsequent argument is supported i.e file.c - file.v 

## Inspiration

* Jim Bumgardner for his excellent tutorial on making annoying rainbows [here](https://krazydad.com/tutorials/makecolors.php)
* And of cource [lolcat](https://github.com/busyloop/lolcat)
