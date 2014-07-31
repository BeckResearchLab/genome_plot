{
	split($1, a, "|");
	locus_tag = a[2];
	type = $3;
	n = split($2, a, "+");
	strand = "+";
	if (n == 1) {
		n = split($2, a, "-");
		strand = "-";
	}
	locus = a[1];
	len = a[2];
	n = split(locus, a, "_");
	start = a[n];
	locus = a[1];
	for (i = 2; i < n; ++i)
		locus = locus "_" a[i];
	if (strand == "+")
		end = (start + len) - 1;
	else
		end = (start - len) + 1;
	product = $4;
	note = $6;
	printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
		locus_tag, type, locus, strand, start, end, product, "", note);
}
