SIG = 0.05
SIG = 0.1

all: genome_plot test

genome_plot: gb2txt.awk draw.awk label.awk

jlw8.gb.txt: jlw8.gb
	awk -f gb2txt.awk jlw8.gb > jlw8.gb.txt

fold_change.dat: download
	./download

jlw8.arrow.color.txt: fold_change.dat
	./values_to_color fold_change.dat 2 0centeredredgreen | awk -F'\t' '{ printf("%s\t%s\n", $$1, $$2); }' > jlw8.arrow.color.txt

jlw8.arrow.size.txt: jlw8.gb.txt
	awk -F'\t' '{ printf("%s\t%f\n", $$1, (line % 3 == 0 ? 1 : (line % 3 == 2 ? 1 : 5))); ++line; }' jlw8.gb.txt > jlw8.arrow.size.txt

jlw8.bar.color.txt: fold_change.dat
	./values_to_color fold_change.dat 4 0centeredredgreen | awk -F'\t' '{ printf("%s\t%s\n", $$1, $$4); }' > jlw8.bar.color.txt

jlw8.astericks.txt: fold_change.dat
	awk -F'\t' '{ if (line > 0) if ($$3 > 0 && $$3 < $(SIG) || $$5 > 0 && $$5 < $(SIG)) printf("%s\t%s\n",  $$1, "*"); ++line; }' fold_change.dat > jlw8.astericks.txt

jlw8.boxes.txt: fold_change.dat
#	awk -F'\t' '{ if (($$3 < $(SIG) || ($$5 > 0 && $$5 < $(SIG))) && (($$2 < 0 && $$4 < 0) || ($$2 > 0 && $$4 > 0))) print $0; }' fold_change.dat  > jlw8.boxes.txt
	awk -F'\t' '{ if (($$3 < $(SIG) && ($$5 > 0 && $$5 < $(SIG))) && (($$2 < 0 && $$4 < 0) || ($$2 > 0 && $$4 > 0))) print $0; }' fold_change.dat  > jlw8.boxes.txt

jlw8.regions.txt: jlw8.gb.txt
	awk -F'\t' -v color="yellow" 'BEGIN { count=1; } { if (line >= 1) { if ($$5 - last < 100) { count++;  } else { printf("%d\t%d\t%s\t%d\n", start, last, color, count); start = $$5; count= 1; }  } else { start = $$5; count++; } ++line; last = $$6; } END { printf("%d\t%d\t%s\t%d\n", start, last, color, count); }' jlw8.gb.txt > jlw8.regions.txt

test: jlw8.gb jlw8.arrow.color.txt jlw8.arrow.size.txt jlw8.bar.color.txt jlw8.astericks.txt jlw8.boxes.txt jlw8.regions.txt
	./genome_plot -d -w 15000 -p 10 -a jlw8.arrow.color.txt -b jlw8.bar.color.txt -k jlw8.astericks.txt -x jlw8.boxes.txt -r jlw8.regions.txt jlw8.gb

clean:
	rm jlw8.gb.txt jlw8.arrow.color.txt jlw8.arrow.size.txt jlw8.bar.color.txt jlw8.astericks.txt jlw8.boxes.txt jlw8.regions.txt
