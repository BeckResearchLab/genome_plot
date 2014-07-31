{
	if (locus == $1) {
		row = int(-$2 / width);
		$2 += row * width;
		if (row < srow && row >= erow) {
			if (colflag) {
				if ($3 > 0) {
					red = 255;
					green = (1 - ($3 / max_abs_mp_value)) * 255;
					blue = green;
				} else {
					green = 255;
					red = (1 - (($3 * -1) / max_abs_mp_value)) * 255;
					blue = red;
				}
			} else {
				red = 128;
				green = 128;
				blue = 128;
			}
			printf("set arrow from %d,%d to %d,%f as 1 lw 0.5 lt rgb \"#%02x%02x%02x\"\n", $2, row - .1, $2, row + ($3 / max_abs_mp_value) * .5, red, green, blue);
		}
	}
}
