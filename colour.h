#pragma once

#include <stdio.h>

struct Colour {
  double spread;
  double freq;
  bool invert;
};

unsigned int rgb_fputs(
  const char* str,
  size_t len,
  const struct Colour* colour,
  unsigned int seed,
  FILE* fp
);

inline unsigned int rgb_puts(
  const char* str,
  size_t len,
  const struct Colour* colour,
  unsigned int seed
) {
  return rgb_fputs(str, len, colour, seed, stdout);
}

int detect_colour_support();
