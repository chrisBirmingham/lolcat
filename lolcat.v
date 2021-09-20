module main

import math
import term

const (
	default_freqency = 0.3
	hue_width = 127
	hue_centre = 128
)

fn get_colour(char string, freq f32, inc int) string {
	red := int(math.sin(freq * inc + 0) * hue_width + hue_centre)
	green := int(math.sin(freq * inc + 2) * hue_width + hue_centre)
	blue := int(math.sin(freq * inc + 4) * hue_width + hue_centre)
	return term.rgb(red, green, blue, char)
}

fn colourise_text(text string, freq f32) string {
	mut output := ''
	characters := text.split('')

	for inc, char in characters {
		output += get_colour(char, freq, inc)
	}

	return output
}

fn main() {
	text := colourise_text('Hello world', f32(default_freqency))
	println(text)
}

