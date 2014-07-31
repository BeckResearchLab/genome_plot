{
	row = int(-$5 / width);
	$5 += row * width;
	$6 += row * width;

	if (row < srow && row >= erow) {
		start = ($4 == "+" ? $5 : $6);
		end = ($4 == "+" ? $6 : $5);
		color = $10;
		size = $11;
		printf("set arrow from %d,%d to %d,%d as 2 lw %f lt rgb \"%s\"\n", start, row, end, row, size, color);
	}
}
