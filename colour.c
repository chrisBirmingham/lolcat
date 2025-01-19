#include <errno.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <wctype.h>
#include "colour.h"

enum ColourSupport {
  COLOUR_TRUE,
  COLOUR_256
};

static const int HUE_WIDTH = 127;
static const int HUE_CENTRE = 128;
static enum ColourSupport COLOUR_SUPPORT = COLOUR_TRUE;

static inline int ansi_domain(int c)
{
  return 6 * (c / 256.0);
}

static inline int true_colour(double angle)
{
  return sin(angle) * HUE_WIDTH + HUE_CENTRE;
}

static int truecolour2rgb(int r, int g, int b)
{
  float sep = 42.5;

  while (r > sep && g > sep && b > sep) {
    sep += 42.5;
  }

  bool gray = r < sep && g < sep && b < sep;

  if (gray) {
    float c = (r + g + b) / 33.0;
    return 232 + roundf(c);
  }

  return 16 + ansi_domain(r) * 36 +
    ansi_domain(g) * 6 +
    ansi_domain(b);
}

static void rgb_fputc(wchar_t c, double angle, FILE* fp)
{
  double pi = acos(-1);
  int r = true_colour(angle);
  int g = true_colour(angle + 2 * pi / 3);
  int b = true_colour(angle + 4 * pi / 3);

  bool is_cntrl = iswcntrl(c) && c != 9 && c != 10;

  if (is_cntrl) {
    c = (c == 127) ? '?' : (c + 64);
  } 

  if (COLOUR_SUPPORT == COLOUR_256) {
    int rgb = truecolour2rgb(r, g, b);
    fprintf(fp, is_cntrl ? "\x1b[38;5;%dm^%lc" : "\x1b[38;5;%dm%lc", rgb, c);
  } else {
    fprintf(fp, is_cntrl ? "\x1b[38;2;%d;%d;%dm^%lc" : "\x1b[38;2;%d;%d;%dm%lc", r, g, b, c);
  }
}

int rgb_fputs(const char* str, size_t len, const struct Colour* colour, int seed, FILE* fp)
{
  const char* end = str + len;
  wchar_t c;

  if (colour->invert) {
    fputs("\x1b[7m", stdout);
  }

  mbstate_t mb = {0};

  for (size_t ret = 0; str < end; str += ret, seed++) {
    ret = mbrtowc(&c, str, end - str, &mb);

    /** 
     * If we encounter an invalid character, print the replacement character
     * and skip over the invalid byte
     */
    if (errno == EILSEQ) {
      errno = 0;
      c = L'\uFFFD';
      ret = 1;
    }

    /**
     * mbrtowc returns 0 when it encounters a null byte within a string. 
     * Increment over it otherwise we'll prematurely leave the loop
     */
    if (ret == 0) {
      ret = 1;
    }

    double angle = colour->freq * (seed / colour->spread);
    rgb_fputc(c, angle, fp);
  }

  fputs("\x1b[39m", fp);

  if (colour->invert) {
    fputs("\x1b[27m", stdout);
  }

  return seed;
}

int rgb_puts(const char* str, size_t len, const struct Colour* colour, int seed)
{
  return rgb_fputs(str, len, colour, seed, stdout);
}

int detect_colour_support()
{
  COLOUR_SUPPORT = COLOUR_TRUE;

  const char* no_colour = getenv("NO_COLOR");

  if (no_colour != NULL && no_colour[0] != '\0') {
    return -1;
  }

  const char* colour_term = getenv("COLORTERM");

  if (colour_term != NULL && 
    (strcmp(colour_term, "truecolor") == 0 || strcmp(colour_term, "24bit") == 0)) {
      return 0;
  }

  const char* term = getenv("TERM");

  if (term == NULL || strcmp(term, "dumb") == 0) {
    return -1;
  }

  if (strstr(term, "-256color") != NULL) {
    COLOUR_SUPPORT = COLOUR_256;
  } else if (strstr(term, "-truecolor") != NULL) {
    COLOUR_SUPPORT = COLOUR_TRUE;
  }

  return 0;
}
