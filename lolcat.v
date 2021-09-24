module main

import colour
import os

fn main() {
	file := os.open('lolcat.v') ?
	mut colour_generator := colour.new_colour_generator()
	output := colour_generator.colourise_file(file, freq: 0.3)

	print(output)
}

