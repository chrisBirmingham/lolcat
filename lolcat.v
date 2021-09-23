module main

import io
import math
import os
import term

const (
	default_freqency = 0.3
	default_hue_width = 127
	default_hue_centre = 128
)

struct ColourConfig {
	freq f32 = default_freqency
	hue_width int = default_hue_width
	hue_centre int = default_hue_centre
}

struct ColourGenerator {
	freq f32
	hue_width int
	hue_centre int
mut:
	inc int
}

fn (c ColourGenerator) get_colour(char string) string {
	red := int(math.sin(c.freq * c.inc + 0) * c.hue_width + c.hue_centre)
	green := int(math.sin(c.freq * c.inc + 2) * c.hue_width + c.hue_centre)
	blue := int(math.sin(c.freq * c.inc + 4) * c.hue_width + c.hue_centre)
	return term.rgb(red, green, blue, char)
}

fn (mut c ColourGenerator) colourise_text(text string) string {
	mut output := ''
	characters := text.split('')
	c.inc = 0

	for char in characters {
		output += c.get_colour(char)
		c.inc += 1
	}

	return output
}

fn new_colour_generator(c ColourConfig) &ColourGenerator {
	return &ColourGenerator {
		c.freq,
		c.hue_width,
		c.hue_centre,
		0
	}
}

fn read_file(file os.File) {
	mut colour_generator := new_colour_generator(freq: 0.2)
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		println(colour_generator.colourise_text(line))
	}
}

fn main() {
	file := os.open('lolcat.v') ?
	//file := os.stdin()
	read_file(file)
}

