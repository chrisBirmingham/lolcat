module stdin

import os

pub struct StdinReader {}

pub fn new_stdin_reader() &StdinReader {
	return &StdinReader{}
}

// Implements the reader interface
pub fn (s StdinReader) read(mut buf []u8) !int {
	line := os.get_raw_line()
	copy(mut buf, line.bytes())
	return line.len
}
