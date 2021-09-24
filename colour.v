module colour

import io
import math
import os
import term

const (
	default_freqency = 0.3
	default_hue_width = 127
	default_hue_centre = 128
)

pub struct ColourConfig {
	freq f32 = default_freqency
	hue_width int = default_hue_width
	hue_centre int = default_hue_centre
}

pub struct ColourGenerator {
	freq f32
	hue_width int
	hue_centre int
mut:
	checkpoint int
	in_file bool
}

fn (c ColourGenerator) get_colour(char string, inc int) string {
	red := int(math.sin(c.freq * inc + 0) * c.hue_width + c.hue_centre)
	green := int(math.sin(c.freq * inc + 2) * c.hue_width + c.hue_centre)
	blue := int(math.sin(c.freq * inc + 4) * c.hue_width + c.hue_centre)
	return term.rgb(red, green, blue, char)
}

pub fn (mut c ColourGenerator) colourise_text(text string) string {
	mut output := ''
	characters := text.split('')
	mut inc := if c.in_file { c.checkpoint } else { 0 }

	for char in characters {
		output += c.get_colour(char, inc)
		inc += 1
	}

	if c.in_file {
		c.checkpoint = inc
	}

	return output
}

pub fn (mut c ColourGenerator) colourise_file(file os.File) string {
	c.in_file = true
	c.checkpoint = 0

	mut output := ''
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		output += c.colourise_text(line) + "\n"
	}

	c.in_file = false
	return output
}

pub fn new_colour_generator(c ColourConfig) &ColourGenerator {
	return &ColourGenerator {
		c.freq,
		c.hue_width,
		c.hue_centre,
		0,
		false
	}
}

