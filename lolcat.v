module main

import cli
import colour
import io
import os
import rand

const (
	application_name = 'lolcat'
	application_version = '1.0.1'
	stdin = '-'
)

struct AppConfig {
	freq f32
	spread int
	invert bool
mut:
	seed int
}

fn colourise_file(file os.File, config AppConfig) int {
	mut checkpoint := config.seed
	freqency := config.freq
	spread := config.spread
	invert := config.invert
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		checkpoint += 1

		output := colour.colourise_text(
			line,
			freq: freqency,
			seed: checkpoint,
			spread: spread,
			invert: invert
		)
		println(output)

		checkpoint += output.len / spread
	}

	return checkpoint
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

	mut app_config := AppConfig {
		f32(freq),
		spread,
		invert
		seed
	}

	files := if cmd.args.len == 0 {
		[stdin]
	} else {
		cmd.args
	}

	for file_name in files {
		mut file := if file_name == stdin {
			os.stdin()
		} else {
			os.open(file_name) or {
				eprintln('lolcat: $file_name: No such file or directory')
				exit(1)
			}
		}

		app_config.seed = colourise_file(file, app_config)

		if file_name != stdin {
			file.close()
		}
	}
}

fn main() {
	mut app := cli.Command{
		name: application_name
		description: 'Concatenate FILE(s), or standard input, to standard output.
With no FILE read standard input.'
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
		default_value: ['4']
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
