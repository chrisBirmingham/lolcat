module stdin

import os

struct StdinReader {}

pub fn new_stdin_reader() &StdinReader {
	return &StdinReader{}
}

pub fn (s StdinReader) read(mut buf []byte) ?int {
	line := os.get_raw_line()
	copy(buf, line.bytes())
	return line.len
}

