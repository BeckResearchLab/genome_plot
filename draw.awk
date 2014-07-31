BEGIN {
	printf("# --- begin draw: start_col = %d, end_col = %d, color_col = %d, size_col = %d, srow = %d, erow = %d, width = %d, offset = %f, nohead = %d, debug = %d\n", start_col, end_col, color_col, size_col, srow, erow, width, offset, nohead, debug);
}

{
	HEAD   = 2;	# arrow styles used in gnuplot for a headed arrow
	NOHEAD = 3;	# or an arrow with no head, i.e. line
	if (nohead == 1)	# allows a no headed mode
		HEAD = 3;

	linesrow = int(-$start_col / width);
	a = $start_col;
	$start_col += linesrow * width;

	lineerow = int(-$end_col / width);
	b = $end_col;
	$end_col += lineerow * width;

	#printf("#%s\t%d\t%d\t%d\t%d\t%d\t%d\n", $1, a, b, lineerow, linesrow, srow, erow);
	if ($locus_col == locus && ((linesrow < srow && linesrow >= erow) || (lineerow < srow && lineerow >= erow))) {
		start = ($4 == "+" ? $start_col : $end_col);
		end = ($4 == "+" ? $end_col : $start_col);
		color = $color_col;
		size = $size_col;
		if (debug > 0) printf("#%s\tscoord %d\tecoord %d\t%d\t%d\n", $1, a, b, lineerow, linesrow);

		if (lineerow == linesrow) {
			# simple one row line
			arrow_style = HEAD;
			printf("set arrow from %d,%f to %d,%f as %d lw %f lt rgb \"%s\"\n", start, linesrow + offset, end, lineerow + offset, arrow_style, size, color);
		} else {
			# multi-row line
			brow=(linesrow > lineerow ? linesrow : lineerow);
			mrow=(linesrow > lineerow ? lineerow : linesrow);
			if (debug > 0) printf("#multi row, brow = %d, mrow = %d\n", brow, mrow);
			for (i = brow; i >= mrow; --i) {
				if (i == brow) {
					if ($4 == "+") {
						mlstart = $start_col;
						mlend = width;
						arrow_style = NOHEAD;
					} else {
						mlstart = width;
						mlend = $start_col;
						arrow_style = HEAD;
					}
					print_row_break(i, width, size, color);
				} else if (i == mrow) {
					if ($4 == "+") {
						mlstart = 0;
						mlend = $end_col;
						arrow_style = HEAD;
					} else {
						mlstart = $end_col;
						mlend = 0;
						arrow_style = NOHEAD;
					}
					print_row_break(i, 0, size, color);
				} else { 
					mlstart = 0;
					mlend = width;
					print_row_break(i, 0, size, color);
					print_row_break(i, width, size, color);
				}
				if (i < srow && i >= erow)
					printf("set arrow from %d,%f to %d,%f as %d lw %f lt rgb \"%s\" # %d\n", mlstart, i + offset, mlend, i + offset, arrow_style, size, color, i);
			}
		}
	}
}
END {
	printf("# --- end draw: start_col = %d, end_col = %d, color_col = %d, size_col = %d, srow = %d, erow = %d, width = %d, offset = %f, nohead = %d, debug = %d\n", start_col, end_col, color_col, size_col, srow, erow, width, offset, nohead, debug);
}

function print_row_break(row, pos, size, color) {
	xdelta = 50;
	ydelta = 0.05;
	printf("set arrow from %d,%f to %d,%f as %d lw %f lt rgb \"%s\"\n", pos + xdelta, i + offset + ydelta, pos - (xdelta / 2), i + offset + (ydelta / 3), NOHEAD, size, color);
	printf("set arrow from %d,%f to %d,%f as %d lw %f lt rgb \"%s\"\n", pos - (xdelta / 2), i + offset + (ydelta / 3), pos + (xdelta / 2), i + offset - (ydelta / 3), NOHEAD, size, color);
	printf("set arrow from %d,%f to %d,%f as %d lw %f lt rgb \"%s\"\n", pos + (xdelta / 2), i + offset - (ydelta / 3), pos - xdelta, i + offset - ydelta, NOHEAD, size, color);
}
