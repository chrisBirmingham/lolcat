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

struct Colour {
	freqency f32
	hue_width int
	hue_centre int
}

fn (c Colour) get_colour(char string, inc int) string {
	red := int(math.sin(c.freqency * inc + 0) * c.hue_width + c.hue_centre)
	green := int(math.sin(c.freqency * inc + 2) * c.hue_width + c.hue_centre)
	blue := int(math.sin(c.freqency * inc + 4) * c.hue_width + c.hue_centre)
	return term.rgb(red, green, blue, char)
}

fn (c Colour) colourise_text(text string) string {
	mut output := ''
	characters := text.split('')

	for inc, char in characters {
		output += c.get_colour(char, inc)
	}

	return output
}

fn read_file(file os.File) {
	colour := Colour{default_freqency, default_hue_width, default_hue_centre}
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		println(colour.colourise_text(line))
	}
}

fn main() {
	file := os.open('lolcat.v') ?
	//file := os.stdin()
	read_file(file)
}

