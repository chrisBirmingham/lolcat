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

static int TAB = 9;
static int LINE_FEED = 10;

static const int HUE_WIDTH = 127;
static const int HUE_CENTRE = 128;
static const char* TAB_SHIFT = "        ";

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

static void print_char(wchar_t c, double angle, FILE* fp)
{
  double pi = acos(-1);
  int r = true_colour(angle);
  int g = true_colour(angle + 2 * pi / 3);
  int b = true_colour(angle + 4 * pi / 3);

  wchar_t print[3] = {0};

  if (iswcntrl(c) && c != LINE_FEED) {
    print[0] = L'^';
    print[1] = c ^ 0x40;
  } else {
    print[0] = c;
  }

  if (COLOUR_SUPPORT == COLOUR_256) {
    int rgb = truecolour2rgb(r, g, b);
    fprintf(fp, "\x1b[38;5;%dm%S", rgb, print);
  } else {
    fprintf(fp, "\x1b[38;2;%d;%d;%dm%S", r, g, b, print);
  }
}

static int print_str(const char* str, size_t len, const struct Colour* colour, int seed, FILE* fp)
{
  const char* end = str + len;
  wchar_t c;

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

    if (c == TAB) {
      print_str(TAB_SHIFT, 8, colour, seed, fp);
      seed += 7;
      continue;
    }

    double angle = colour->freq * (seed / colour->spread);
    print_char(c, angle, fp);
  }

  return seed;
}

int rgb_fputs(const char* str, size_t len, const struct Colour* colour, int seed, FILE* fp)
{
  if (colour->invert) {
    fputs("\x1b[7m", stdout);
  }

  seed = print_str(str, len, colour, seed, fp);

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
