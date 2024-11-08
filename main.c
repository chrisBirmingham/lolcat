#include <errno.h>
#include <getopt.h>
#include <math.h>
#include <locale.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <wchar.h>

/* Pull in external getopt globals */
extern char* optarg;
extern int optind;
extern int optopt;
extern int opterr; 

const int HUE_WIDTH = 127;
const int HUE_CENTRE = 128;
const float DEFAULT_SPREAD = 2.0;
const float DEFAULT_FREQ = 0.3;
const double PI = 2 * acos(0.0);

typedef struct {
  float spread;
  float freq;
  bool invert;
} ColourOptions;

const ColourOptions default_opts = {
  DEFAULT_SPREAD,
  DEFAULT_FREQ,
  false
};

const char* VERSION = "1.0.0\n";

const char* USAGE = "Usage: lolcat [OPTION]... [FILE]...\n"
"Concatenate FILE(s) to standard output.\n"
"\n"
"With no FILE, or when FILE is -, read standard input.\n"
"\n"
"   -p  Rainbow Spread (Default 3.0)\n"
"   -F  Rainbow Frequency (Default 0.2)\n"
"   -S  Rainbow Seed. 0 = Random (Default 0)\n"
"   -i  Invert fg and bg\n"
"   -v  Print version and exit\n"
"   -h  Show this message and exit\n"
"\n"
"Examples:\n"
"  lolcat f - g  Output f's contents, then standard input, then g's contents.\n"
"  lolcat        Copy standard input to standard output.\n";

static inline int random()
{
  return rand() % 256 + 1;
}

static inline int colour(float angle)
{
  return sin(angle) * HUE_WIDTH + HUE_CENTRE;
}

static void rgb_fputc(FILE* fp, wint_t c, float angle)
{
  int r = colour(angle);
  int g = colour(angle + 2 * PI / 3);
  int b = colour(angle + 4 * PI / 3);
  fprintf(fp, "\x1b[38;2;%d;%d;%dm%lc\x1b[39m", r, g, b, c);
}

static int rgb_fprintf(FILE* fp, const char* str, ColourOptions opts, int seed)
{
  for (; *str; str++) {
    float angle = opts.freq * (seed / opts.spread);
    rgb_fputc(fp, *str, angle);
    seed += 1;
  }

  return seed;
}

static inline int rgb_printf(const char* str, ColourOptions opts, int seed)
{
  return rgb_fprintf(stdout, str, opts, seed);
}

static int colourise_file(FILE* fp, ColourOptions opts, int seed)
{
  wint_t c;
  
  if (opts.invert) {
    printf("\x1b[7m");
  }

  while ((c = fgetwc(fp)) != WEOF) {
    float angle = opts.freq * (seed / opts.spread);
    rgb_fputc(stdout, c, angle);
    seed += 1;
  }

  if (opts.invert) {
    printf("\x1b[27m");
  }

  return seed;
}

static inline bool is_stdin(const char* path)
{
  return (path == NULL || strcmp(path, "-") == 0);
}

static void error(const char* fmt, ...)
{
  va_list args;
  va_start(args, fmt);
  int len = vsnprintf(NULL, 0, fmt, args) + 1;
  char* buf = malloc(len);

  if (buf == NULL) {
    fprintf(stderr, "Failed to allocate memory for error message\n");
    abort();
  }

  va_end(args);

  /* Calling vsnprintf modifed the va_arg, have to reinit with va_start */
  va_start(args, fmt);
  vsnprintf(buf, len, fmt, args);
  va_end(args);
  
  rgb_fprintf(stderr, buf, default_opts, random());
  free(buf);
}

static float float_input(const char* in)
{
  char* err;
  double out = strtod(in, &err);

  /* err points to the character after the last processed number, if it's not
   * equal to \0 then we didn't complete the string */
  if (*err != '\0') {
    return -1;
  }

  return out;
}

static int int_input(const char* in)
{
  char* err;
  unsigned long int out = strtoul(in, &err, 10);

  if (*err != '\0') {
    return -1;
  }

  return out;
}

int main(int argc, char** argv)
{
  setlocale(LC_ALL, "");
  srand(time(NULL));

  int opt;
  int seed = 0;
  bool invert = false;
  float spread = DEFAULT_SPREAD;
  float freq = DEFAULT_FREQ;

  opterr = 0; /* Disable getopts default error to stderr */
  while ((opt = getopt(argc, argv, "p:F:S:ivh")) != -1) {
    switch (opt) {
      case 'v':
        rgb_printf(VERSION, default_opts, random());
        return EXIT_SUCCESS;
      case 'h':
        rgb_printf(USAGE, default_opts, random());
        return EXIT_SUCCESS;
      case 'S':
        seed = int_input(optarg);
        if (seed < 0) {
          error("lolcat: Invalid seed provided (%s)\n", optarg);
          return EXIT_FAILURE;
        }
        break;
      case 'p':
        spread = float_input(optarg);
        if (spread <= 0) {
          error("lolcat: Invalid spread provided (%s)\n", optarg);
          return EXIT_FAILURE;
        }
        break;
      case 'F':
        freq = float_input(optarg);
        if (freq <= 0) {
          error("lolcat: Invalid frequency provided (%s)\n", optarg);
          return EXIT_FAILURE;
        }
        break;
      case 'i':
        invert = true;
        break;
      case '?':
        if (optopt == 'S' || optopt == 'p' || optopt == 'F') {
          error("lolcat: Option -%c requires an argument\n", optopt);
        } else {
          error("lolcat: Unknown option -%c\n", optopt);
        }
        error("Try 'lolcat -h' for more information\n");
        return EXIT_FAILURE;
    }
  }

  if (seed == 0) {
    seed = random();
  }

  ColourOptions opts = {
    spread,
    freq,
    invert
  };

  do {
    const char* path = argv[optind];
    FILE* fp = stdin;
    
    if (!is_stdin(path) && ((fp = fopen(path, "r")) == NULL)) {
      error("lolcat: %s: %s\n", path, strerror(errno));
      return EXIT_FAILURE;
    }

    seed = colourise_file(fp, opts, seed);

    if (!is_stdin(path)) {
      fclose(fp);
    }
  } while (++optind < argc);

  return EXIT_SUCCESS;
}

