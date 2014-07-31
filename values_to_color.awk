{
	if (line > 0) {
		value[line] = $col;
	}

	lines[line] = $0; ++line;
}

END {
	min = 32768;
	max = -1;

	for (i = 1; i < line; ++i) {
		if (value[i] < min) min = value[i];
		if (value[i] > max) max = value[i];
	}

	if (option == "0centeredredgreen") {
		min = min -5
		max = max +5
	} else {
		min = log(min);
		if (min < 0) min = 0;
		max = log(max);
	}

	printf("%s\n", lines[0]);
	for (i = 1; i < line; ++i) {
		color = value_to_color(value[i]);
		n=split(lines[i], cols, FS); 
		printf("%s", cols[1]); 
		for (j = 2; j <= n; ++j) { 
			if (j == col)
				v = color; 
			else
				v = cols[j];
			printf("\t%s", v);
		}
		printf("\t%f", value[i]);
		printf("\n");
	}
}

function value_to_color(value) {
	if (option == "0centeredredgreen") {
		if (value < 0) {
			v = (value / min) * 255;
			color = sprintf("#%02X%02X%02X", 0, v, 0);
		} else {
			v = (value / max) * 255;
			color = sprintf("#%02X%02X%02X", v, 0, 0);
		}
	} else {
		value = log(value);
		if (value < 0) value = 0;
		v = (value - min) / (max - min) * 255.;
		color = sprintf("#%02X%02X%02X", 0, v, 0);
	}
	return color;
}
