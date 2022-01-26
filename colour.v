module colour

import math
import term

const (
	hue_width = 127
	hue_centre = 128
)

pub struct ColourConfig {
pub:
	freq f32
	spread int
	invert bool
	seed int
}

fn colourise_char(c string, freq f32, inc int) string {
	red := int(math.sin(freq * inc + 0) * hue_width + hue_centre)
	green := int(math.sin(freq * inc + 2) * hue_width + hue_centre)
	blue := int(math.sin(freq * inc + 4) * hue_width + hue_centre)
	return term.rgb(red, green, blue, c)
}

fn invert_colour(text string) string {
	return term.inverse(text)
}

pub fn colourise_text(text string, conf ColourConfig) string {
	mut output := ''
	characters := text.split('')

	for i := 0; i < characters.len; i++ {
		output += colourise_char(
			characters[i],
			conf.freq,
			conf.seed + i / conf.spread
		)
	}

	if conf.invert {
		output = invert_colour(output)
	}

	return output
}

