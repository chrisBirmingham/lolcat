module colour

import io
import math
import os
import term

const (
	hue_width = 127
	hue_centre = 128
)

pub struct ColourConfig {
	freq f32
	seed int
	spread int
}

struct Colour {}

pub struct ColourGenerator {
	colour Colour
mut:
	checkpoint int
	in_file bool
}

fn (c Colour) create(
	char string,
	freq f32,
	inc int
) string {
	red := int(math.sin(freq * inc + 0) * hue_width + hue_centre)
	green := int(math.sin(freq * inc + 2) * hue_width + hue_centre)
	blue := int(math.sin(freq * inc + 4) * hue_width + hue_centre)
	return term.rgb(red, green, blue, char)
}

pub fn (mut c ColourGenerator) colourise_text(
	text string,
	conf ColourConfig
) string {
	mut output := ''
	characters := text.split('')
	seed := if c.in_file && c.checkpoint > 0 { c.checkpoint } else { conf.seed }
	mut inc := 0

	for char in characters {
		output += c.colour.create(
			char,
			conf.freq,
			seed + inc / conf.spread
		)
		inc += 1
	}

	if c.in_file {
		c.checkpoint = seed + inc / conf.spread
	}

	return output
}

pub fn (mut c ColourGenerator) colourise_file(
	file os.File,
	conf ColourConfig
) string {
	c.in_file = true
	c.checkpoint = 0

	mut output := ''
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		output += c.colourise_text(line, conf) + "\n"
	}

	c.in_file = false
	return output
}

pub fn new_colour_generator() &ColourGenerator {
	colour := Colour{}
	return &ColourGenerator{
		colour: colour
	}
}

