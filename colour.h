#pragma once

#include <stdio.h>

struct Colour {
  double spread;
  double freq;
  bool invert;
};

int rgb_fputs(const char *str, size_t len, const struct Colour* colour, int seed, FILE* fp);

int rgb_puts(const char* str, size_t len, const struct Colour* colour, int seed);

int detect_colour_support();
