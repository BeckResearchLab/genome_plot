BEGIN {
	printf("# --- begin object: start_col = %d, end_col = %d, color_col = %d, size_col = %d, srow = %d, erow = %d, width = %d, offset = %f, debug = %d\n", start_col, end_col, color_col, size_col, srow, erow, width, offset, debug);
}

{
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
		size = $size_col;
		if (color_col >= 0)
			color = $color_col;
		else {
			if (size > 0)
				color = "magenta";
			else
				color = "green";
		}
		if (debug > 0) printf("#%s\tscoord %d\tecoord %d\t%d\t%d\n", $1, a, b, lineerow, linesrow);

		if (lineerow == linesrow) {
			# simple one row rect
			printf("set object rect from %d,%f to %d,%f back fs solid 1.0 border rgb \"%s\" fc rgb \"%s\"\n", start, linesrow + offset, end, lineerow + offset + size, color, color);
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
					} else {
						mlstart = width;
						mlend = $start_col;
					}
				} else if (i == mrow) {
					if ($4 == "+") {
						mlstart = 0;
						mlend = $end_col;
					} else {
						mlstart = $end_col;
						mlend = 0;
					}
				} else { 
					mlstart = 0;
					mlend = width;
				}
				if (i < srow && i >= erow)
					printf("set object rect from %d,%f to %d,%f back fs solid 1.0 border rgb \"%s\" fc rgb \"%s\"\n", mlstart, i + offset, mlend, i + offset + size, color, color);
			}
		}
	}
}
END {
	printf("# --- end object: start_col = %d, end_col = %d, color_col = %d, size_col = %d, srow = %d, erow = %d, width = %d, offset = %f, debug = %d\n", start_col, end_col, color_col, size_col, srow, erow, width, offset, debug);
}
