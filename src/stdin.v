module stdin

import os

pub struct Reader {}

pub fn Reader.new() Reader {
	return Reader{}
}

// Implements the reader interface
pub fn (r Reader) read(mut buf []u8) !int {
	line := os.get_raw_line()
	copy(mut buf, line.bytes())
	return line.len
}
