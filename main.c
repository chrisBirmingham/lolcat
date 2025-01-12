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
#include <wctype.h>

/* Pull in external getopt globals */
extern char* optarg;
extern int optind;
extern int optopt;
extern int opterr; 

static const int HUE_WIDTH = 127;
static const int HUE_CENTRE = 128;
static const double DEFAULT_SPREAD = 2.0;
static const double DEFAULT_FREQ = 0.3;
static const char* STDIN_ARGV[] = {"-", NULL};

typedef struct {
  double spread;
  double freq;
  bool invert;
} ColourOptions;

const ColourOptions default_opts = {
  DEFAULT_SPREAD,
  DEFAULT_FREQ,
  false
};

static const char* VERSION = "1.0.0\n";

static const char* USAGE = "Usage: lolcat [OPTION]... [FILE]...\n"
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

static void error(const char* fmt, ...)
  __attribute__ ((format (printf, 1, 2)));

static int rand_int()
{
  /**
   * Attempt to reduce modulo bias in standard C rand
   * https://stackoverflow.com/questions/10984974/why-do-people-say-there-is-modulo-bias-when-using-a-random-number-generator
   */
  int max_int = 256;
  int r;
  int range = RAND_MAX - (((RAND_MAX % max_int) + 1) % max_int);

  do {
    r = rand();
  } while (r > range);

  return r % max_int + 1;
}

static inline int colour(double angle)
{
  return sin(angle) * HUE_WIDTH + HUE_CENTRE;
}

static void rgb_fputc(wchar_t c, double angle, FILE* fp)
{
  double pi = acos(-1);
  int r = colour(angle);
  int g = colour(angle + 2 * pi / 3);
  int b = colour(angle + 4 * pi / 3);

  if (iswcntrl(c) && c != 9 && c != 10) {
    c = (c == 127) ? '?' : (c + 64);
    fprintf(fp, "\x1b[38;2;%d;%d;%dm^%lc", r, g, b, c);
  } else {
    fprintf(fp, "\x1b[38;2;%d;%d;%dm%lc", r, g, b, c);
  }
}

static inline void rgb_putc(wchar_t c, double angle)
{
  rgb_fputc(c, angle, stdout);
}

static int rgb_fputs(const char* str, ColourOptions opts, int seed, FILE* fp)
{
  for (; *str; str++, seed++) {
    double angle = opts.freq * (seed / opts.spread);
    rgb_fputc(*str, angle, fp);
  }

  fputs("\x1b[39m", fp);

  return seed;
}

static inline int rgb_puts(const char* str, ColourOptions opts, int seed)
{
  return rgb_fputs(str, opts, seed, stdout);
}

static int colourise_file(FILE* fp, ColourOptions opts, int seed)
{
  wint_t c;
  
  if (opts.invert) {
    fputs("\x1b[7m", stdout);
  }

  while ((c = fgetwc(fp)) != WEOF) {
    double angle = opts.freq * (seed / opts.spread);
    rgb_putc(c, angle);
    seed += 1;
  }

  if (!feof(fp)) {
    error("\nEncountered error while reading stream: %s\n", strerror(errno));
    return -1;
  }

  if (opts.invert) {
    fputs("\x1b[27m", stdout);
  }

  return seed;
}

static inline bool is_stdin(const char* path)
{
  return (strcmp(path, "-") == 0);
}

static void error(const char* fmt, ...)
{
  fflush(stdout);
  va_list args;
  va_start(args, fmt);
  int len = vsnprintf(NULL, 0, fmt, args) + 1;
  char* buf = malloc(len);

  if (buf == NULL) {
    fputs("Failed to allocate memory for error message\n", stderr);
    abort();
  }

  va_end(args);

  /* Calling vsnprintf modifed the va_arg, have to reinit with va_start */
  va_start(args, fmt);
  vsnprintf(buf, len, fmt, args);
  va_end(args);
  
  rgb_fputs(buf, default_opts, rand_int(), stderr);
  free(buf);
}

static double float_input(const char* in)
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

static FILE* open_file(const char* path)
{
  FILE* fp = stdin;

  if (!is_stdin(path)) {
    fp = fopen(path, "r");
  }

  return fp;
}

static int cat(char** argv, ColourOptions opts, int seed)
{
  /* argv modification influenced by busybox */
  if (*argv == NULL) {
    argv = (char**)&STDIN_ARGV;
  }

  do {
    const char* path = *argv;
    FILE* fp = open_file(path);

    if (fp == NULL) {
      error("lolcat: %s: %s\n", path, strerror(errno));
      return EXIT_FAILURE;
    }

    seed = colourise_file(fp, opts, seed);

    if (seed < 0) {
      return EXIT_FAILURE;
    }

    if (!is_stdin(path)) {
      fclose(fp);
    }
  } while (*++argv);

  return EXIT_SUCCESS;
}

int main(int argc, char** argv)
{
  if (setlocale(LC_ALL, "") == NULL) {
    fputs("Failed to set locale\n", stderr);
    abort();
  }

  srand(time(NULL));

  int opt;
  int seed = 0;
  bool invert = false;
  double spread = DEFAULT_SPREAD;
  double freq = DEFAULT_FREQ;

  opterr = 0; /* Disable getopts default error to stderr */
  while ((opt = getopt(argc, argv, "p:F:S:ivh")) != -1) {
    switch (opt) {
      case 'v':
        rgb_puts(VERSION, default_opts, rand_int());
        return EXIT_SUCCESS;
      case 'h':
        rgb_puts(USAGE, default_opts, rand_int());
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

  seed = !seed ? rand_int() : seed;

  ColourOptions opts = {
    spread,
    freq,
    invert
  };

  argv += optind;

  return cat(argv, opts, seed);
}

