BEGIN {
	definition = "";
	in_features = 0;
	in_features_cds = 0;
	cds = -1;
}
/^LOCUS/ { locus = $2; }
/^DEFINITION/ { for (i = 2; i <= NF; ++i) definition = definition $i " "; }
/^FEATURES/ { in_features = 1; }
/^ORIGIN/ { in_features = 0; }
/^     gene/ { in_features_cds = 0; }
/^     sig_peptide/ { in_features_cds = 0; }
// {
	if (in_features) {
		tag = substr($0, 1, 9);
		if ( tag == "     CDS " || tag == "     rRNA" || tag == "     tRNA" ) {
			in_features_cds = 1;
			cds++;
			if (substr($2, 1, 10) == "complement") {
				orf[cds, "strand"] = "-";
				if (substr($2, 12, 4) == "join") {
					n = split(substr($2, 17, length($2) - 17), range, "[\.]");
					range[3] = range[n];
				} else {
					split(substr($2, 12, length($2) - 12), range, "[\.]");
				}
				orf[cds, "start"] = range[1];
				orf[cds, "end"] = range[3];
			} else {
				orf[cds, "strand"] = "+";
				if (substr($2, 1, 4) == "join") {
					n = split(substr($2, 5, length($2) - 5), range, "[\.]");
					range[3] = range[n];
				} else {
					split($2, range, "[\.]");
				}
				orf[cds, "start"] = range[1];
				orf[cds, "end"] = range[3];
			}
			orf[cds, "type"] = $1;
		} else if (in_features_cds) {
			if (index($1, "/") == 1) {
				in_note = 0;
				in_product = 0;
				in_translation = 0;
				label = extract_label($1);
				data = extract_data($0);
				orf[cds, label] = data;
				if (label == "note" && substr($1, length($1), 1) != "\"")
					in_note = 1;
				else if (label == "product" && substr($1, length($1), 1) != "\"")
					in_product = 1;
				else if (label == "translation") {
					if (substr($1, length($1), 1) == "\"")
						in_features_cds = 0;
					else
						in_translation = 1;
				}
			} else if (in_note) {
				if (index($0, "\"") == length($0)) {
					sub("\"", "", $0);
					in_note = 0;
				}
				orf[cds, label] = orf[cds, label] " " trim($0);
			} else if (in_product) {
				if (index($0, "\"") == length($0)) {
					sub("\"", "", $0);
					in_product = 0;
				}
				orf[cds, label] = orf[cds, label] " " trim($0);
			} else if (in_translation) {
				if (index($1, "\"") == length($1)) {
					sub("\"", "", $1);
					in_translation = 0;
					in_features_cds = 0;
				}
				orf[cds, label] = orf[cds, label] $1;
			}
		}
		orf[cds, "locus"] = locus;
	}
}
END {
	# printf("definition:\n\t%s\n", definition);
	for (i = 0; i <= cds; ++i) {
		printf("%s\t%s\t%s\t%c\t%s\t%s\t%s\t%s\t%s\n", orf[i, "locus_tag"], orf[i, "type"], orf[i, "locus"], orf[i, "strand"], orf[i, "start"], orf[i, "end"], orf[i, "product"], orf[i, "translation"], orf[i, "note"]);
	}
}
function extract_label(field) {
	return substr(field, 2, index(field, "=") - 2);
}
function extract_data(line) {
	split(line, first, "=")
	split(first[2], second, "\"");
	return second[2];
}
function ltrim(s) { sub(/^[ \t]+/, "", s); return s }
function rtrim(s) { sub(/[ \t]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }
