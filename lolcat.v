module main

import cli
import colour
import os

const (
	application_name = 'lolcat'
	application_version = '1.0.0'
)

fn colourise_file(file_name string, mut colour_generator colour.ColourGenerator) {
	mut file := os.open(file_name) or {
		eprintln('lolcat: $file_name: No such file or directory')
		exit(1)
	}

	defer {
		file.close()
	}

	output := colour_generator.colourise_file(file, freq: 0.3)
	print(output)
}

fn colourise_stdin(mut colour_generator colour.ColourGenerator) {
	file := os.stdin()
	output := colour_generator.colourise_file(file, freq: 0.3)
	print(output)
}

fn run_application(cmd cli.Command) ? {
	mut colour_generator := colour.new_colour_generator()

	if cmd.args.len == 0 {
		colourise_stdin(mut colour_generator)
	} else {
		for file_name in cmd.args {
			colourise_file(file_name, mut colour_generator)
		}
	}
}

fn main() {
	mut app := cli.Command{
		name: application_name
		description: 'Concatenate FILE(s), or standard input, to standard output.
With no FILE, or when FILE is -, read standard input.'
		execute: run_application
		posix_mode: true,
		version: application_version
	}

	app.setup()
	app.parse(os.args)
}

