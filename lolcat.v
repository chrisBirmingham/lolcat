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

struct StdinWrapper {}

fn (s StdinWrapper) read(mut buf []byte) ?int {
	line := os.get_raw_line()
	copy(buf, line.bytes())
	return line.len
}

struct App {
mut:
	checkpoint int
}

fn new_app() &App{
	return &App{}
}

fn (mut a App) colourise_file(
	file io.Reader,
	conf colour.ColourConfig
) {
	freqency := conf.freq
	spread := conf.spread
	invert := conf.invert
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or {
			break
		}

		a.checkpoint += 1

		output := colour.colourise_text(
			line,
			freq: freqency,
			seed: a.checkpoint,
			spread: spread,
			invert: invert
		)
		println(output)

		a.checkpoint += output.len / spread
	}
}

fn (mut a App) run(files []string, conf colour.ColourConfig) {
	a.checkpoint = conf.seed
	for file_name in files {
		if file_name == stdin {
			a.colourise_file(StdinWrapper{}, conf)
			continue
		}

		mut file :=	os.open(file_name) or {
			eprintln('lolcat: $file_name: No such file or directory')
			exit(1)
		}

		a.colourise_file(file, conf)

		file.close()
	}
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

	mut app := new_app()

	files := if cmd.args.len == 0 {
		[stdin]
	} else {
		cmd.args
	}

	app.run(
		files,
		freq: f32(freq),
		spread: spread,
		invert: invert
		seed: seed
	)
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
