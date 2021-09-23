module colour

import math
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
	inc int
}

fn (c ColourGenerator) get_colour(char string) string {
	red := int(math.sin(c.freq * c.inc + 0) * c.hue_width + c.hue_centre)
	green := int(math.sin(c.freq * c.inc + 2) * c.hue_width + c.hue_centre)
	blue := int(math.sin(c.freq * c.inc + 4) * c.hue_width + c.hue_centre)
	return term.rgb(red, green, blue, char)
}

pub fn (mut c ColourGenerator) colourise_text(text string) string {
	mut output := ''
	characters := text.split('')
	c.inc = 0

	for char in characters {
		output += c.get_colour(char)
		c.inc += 1
	}

	return output
}

pub fn new_colour_generator(c ColourConfig) &ColourGenerator {
	return &ColourGenerator {
		c.freq,
		c.hue_width,
		c.hue_centre,
		0
	}
}

