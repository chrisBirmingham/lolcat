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
mut:
	checkpoint int
	in_file bool
}

fn (c ColourGenerator) get_colour(
	char string,
	freq f32,
	inc int,
	hue_width int,
	hue_centre int
) string {
	red := int(math.sin(freq * inc + 0) * hue_width + hue_centre)
	green := int(math.sin(freq * inc + 2) * hue_width + hue_centre)
	blue := int(math.sin(freq * inc + 4) * hue_width + hue_centre)
	return term.rgb(red, green, blue, char)
}

pub fn (mut c ColourGenerator) colourise_text(text string, conf ColourConfig) string {
	mut output := ''
	characters := text.split('')
	mut inc := if c.in_file { c.checkpoint } else { 0 }

	for char in characters {
		output += c.get_colour(
			char,
			conf.freq,
			inc,
			conf.hue_width,
			conf.hue_centre
		)
		inc += 1
	}

	if c.in_file {
		c.checkpoint = inc
	}

	return output
}

pub fn (mut c ColourGenerator) colourise_file(file os.File, conf ColourConfig) string {
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
	return &ColourGenerator {
		0,
		false
	}
}

