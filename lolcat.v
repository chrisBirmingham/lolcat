module main

import cli
import colour
import os
import rand

const (
	application_name = 'lolcat'
	application_version = '1.0.0'
)

fn colourise_file(file_name string, colour_config colour.ColourConfig) {
	mut colour_generator := colour.new_colour_generator()

	mut file := os.open(file_name) or {
		eprintln('lolcat: $file_name: No such file or directory')
		exit(1)
	}

	defer {
		file.close()
	}

	output := colour_generator.colourise_file(file, colour_config)
	print(output)
}

fn colourise_stdin(colour_config colour.ColourConfig) {
	mut colour_generator := colour.new_colour_generator()

	file := os.stdin()
	output := colour_generator.colourise_file(file, colour_config)
	print(output)
}

fn run_application(cmd cli.Command) ? {
	freq := cmd.flags.get_float('freq') ?
	mut seed := cmd.flags.get_int('seed') ?
	spread := cmd.flags.get_int('spread') ?
	invert := cmd.flags.get_bool('invert') ?

	if seed == 0 {
		seed = rand.int_in_range(0, 256)
	}

	if spread <= 0 {
		eprintln('Spread must be greater than zero')
		exit(1)
	}

	if freq <= 0 {
		eprintln('Freqency must be greater than zero')
		exit(1)
	}

	config := colour.ColourConfig {
		freq: f32(freq)
		seed: seed,
		spread: spread,
		invert: invert
	}

	if cmd.args.len == 0 {
		colourise_stdin(config)
	} else {
		for file_name in cmd.args {
			colourise_file(file_name, config)
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

	app.add_flag(cli.Flag{
		flag: .float
		required: false
		name: 'freq'
		abbrev: 'f'
		description: 'Rainbow frequency'
		default_value: ['0.2']
	})

	app.add_flag(cli.Flag{
		flag: .int
		required: false
		name: 'seed'
		abbrev: 's'
		description: 'Rainbow seed'
		default_value: ['0']
	})

	app.add_flag(cli.Flag{
		flag: .int
		required: false
		name: 'spread'
		abbrev: 'S'
		description: 'Rainbow spread'
		default_value: ['3']
	})

	app.add_flag(cli.Flag{
		flag: .bool
		required: false
		name: 'invert'
		abbrev: 'i'
		description: 'Invert fg and bg'
		default_value: ['false']
	})

	app.setup()
	app.parse(os.args)
}

