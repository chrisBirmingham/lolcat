module main

import cli
import colour
import io
import os
import rand
import stdin
import v.vmod

const (
	exit_failure = 1
	stdin = '-'
)

struct App {
	name string
	stdin_reader stdin.Reader
mut:
	checkpoint int
}

fn App.new(name string) App {
	return App{
		name: name
		stdin_reader: stdin.Reader.new()
	}
}

fn (mut a App) colourise_file(file io.Reader, conf colour.Config) {
	mut reader := io.new_buffered_reader(reader: file)

	for {
		line := reader.read_line() or { break }

		a.checkpoint += 1

		child_conf := colour.Config{...conf, seed: a.checkpoint}
		output := colour.colourise_text(line, child_conf)
		println(output)

		a.checkpoint += output.len / conf.spread
	}
}

fn (mut a App) run(files []string, conf colour.Config) {
	a.checkpoint = conf.seed
	for file_name in files {
		if file_name == stdin {
			a.colourise_file(a.stdin_reader, conf)
			continue
		}

		mut file := os.open(file_name) or {
			eprintln('${a.name}: ${file_name}: No such file or directory')
			exit(exit_failure)
		}

		a.colourise_file(file, conf)

		file.close()
	}
}

fn run_application(cmd cli.Command) ! {
	freq := cmd.flags.get_float('freq')!
	mut seed := cmd.flags.get_int('seed')!
	spread := cmd.flags.get_int('spread')!
	invert := cmd.flags.get_bool('invert')!
	help := cmd.flags.get_bool('help')!
	version := cmd.flags.get_bool('version')!

	if seed == 0 {
		seed = rand.int_in_range(0, 256) or {
			eprintln('Failed to generate random colour seed')
			exit(exit_failure)
		}
	}

	if spread <= 0 {
		eprintln('Spread must be greater than zero')
		exit(exit_failure)
	}

	if freq <= 0 {
		eprintln('Freqency must be greater than zero')
		exit(exit_failure)
	}

	colour_config := colour.Config{f32(freq), spread, invert, seed}

	if help {
		println(colour.colourise_text(cmd.help_message(), colour_config))
		return
	}

	if version {
		println(colour.colourise_text('${cmd.name} version ${cmd.version}', colour_config))
		return
	}

	mut app := App.new(cmd.name)

	files := if cmd.args.len == 0 {
		[stdin]
	} else {
		cmd.args
	}

	app.run(files, colour_config)
}

fn main() {
	mod := vmod.decode(@VMOD_FILE) or {
		eprintln('Failure to read v.mod file. Reason: ${err.msg()}')
		exit(exit_failure)
	}

	mut app := cli.Command{
		name: mod.name
		description: 'Concatenate FILE(s), or standard input, to standard output.
With no FILE read standard input.'
		execute: run_application
		posix_mode: true
		disable_man: true
		disable_help: true
		disable_version: true
		version: mod.version
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

	app.add_flag(cli.Flag{
		flag: .bool
		required: false
		name: 'help'
		abbrev: 'h'
		description: 'Display this help'
		default_value: ['false']
	})

	app.add_flag(cli.Flag{
		flag: .bool
		required: false
		name: 'version'
		abbrev: 'v'
		description: 'Prints version information'
		default_value: ['false']
	})

	app.setup()
	app.parse(os.args)
}
