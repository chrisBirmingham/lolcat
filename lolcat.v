module main

import colour
import io
import os

fn read_file(file os.File) {
	mut colour_generator := colour.new_colour_generator(freq: 0.2)
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

