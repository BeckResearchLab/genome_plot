BEGIN {
	printf("# --- begin label: start_col = %d, end_col = %d, label_col = %d, srow = %d, erow = %d, width = %d, offset = %f, truncate = %d, label_every = %d, debug = %d\n", start_col, end_col, label_col, srow, erow, width, offset, truncate, label_every, debug);
	if (label_every < 1) label_every = 1;
}

{
	labelsrow = int(-$start_col / width);
	a = $start_col;
	$start_col += labelsrow * width;

	labelerow = int(-$end_col / width);
	b = $end_col;
	$end_col += labelerow * width;

	if (debug > 0)
		printf("#locus %s\tlabel %s\tlabelsrow %s\tsrow %s\tlabelerow %s\terow %s\n", locus, $label_col, labelsrow, srow, labelerow, erow);

	if (($locus_col == locus) && ((labelsrow < srow && labelsrow >= erow) || (labelerow < srow && labelerow >= erow))) {
	    if (debug > 0) printf("#%s\tlabel_number %d\tlabel_every %d\tlabelmod %d\n", $1, label_number, label_every, (label_number % label_every));
	    if (label_number % label_every == 0) {
		start = ($4 == "+" ? $start_col : $end_col);
		end = ($4 == "+" ? $end_col : $start_col);
		if (debug > 0) printf("#%s\tscoord %d\tecoord %d\t%d\t%d\n", $1, a, b, labelerow, labelsrow);

		if (labelerow == labelsrow) {
			# simple one row label
			if (truncate) {
				label = substr($label_col, 1, ($end_col - $start_col) / 100);
			} else {
				label = $label_col
			}
			sub("_", "\\\\_", label);
			printf("set label \"%s\" at %d,%f\n", label, $start_col, labelsrow + offset);
		} else {
			# multi-row label
			# place on row with most room
			brow=(labelsrow > labelerow ? labelsrow : labelerow);
			mrow=(labelsrow > labelerow ? labelerow : labelsrow);
			if (debug > 0) printf("#multi row, brow = %d, mrow = %d\n", brow, mrow);
			mra = 0;
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
				if (abs(mlend - mlstart) > mra) {
					mra = abs(mlend - mlstart);
					mra_start = (mlstart < mlend ? mlstart : mlend);
					mra_end = mlend;
					mra_i = i;
				}
			}
			# if the label location is on this page in the case of an ORF that spans pages, otherwise skip
			if (mra_i < srow && mra_i >= erow) {
				if (truncate) 
					label = substr($label_col, 1, (mra) / 100);
				else
					label = $label_col;
				sub("_", "\\\\_", label);
				printf("set label \"%s\" at %d,%f\n", label, mra_start, mra_i + offset);
			}
		}
	    }
	    label_number++;
	    if (label_number >= label_every) label_number = 0;
	}
}
END {
	printf("# --- end label: start_col = %d, end_col = %d, label_col = %d, srow = %d, erow = %d, width = %d, offset = %f, truncate = %d, label_every = %d, debug = %d\n", start_col, end_col, label_col, srow, erow, width, offset, truncate, label_every, debug);
}

function abs(x, y) {
	r = x - y;
	if (r < 0) r *= -1;
	return r;
}
