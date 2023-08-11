rm strand_count_stat.tsv &>/dev/null
for s in `cat sample.list`
do
	echo -ne "$s\t" >>strand_count_stat.tsv
	perl -ane 'print(join("\t", ($F[0], $F[1], $F[1] / $F[0] * 100)), "\n")' $s/strand_count.tsv >>strand_count_stat.tsv
done

perl -ane '$F[0] =~ s/_n\d+$//; print($F[0], "\t", $F[3], "\n")' strand_count_stat.tsv >tmp
tsv_group_mean.py tmp 0 >antisense_mean_rate.tsv
