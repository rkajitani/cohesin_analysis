# ENSG00000204348 DOM3Z
# ENSG00000088930 XRN2
# ENSG00000107371 EXOSC3

for g in ENSG00000088930 ENSG00000107371
do
	for s in `cat sample.list`
	do
		echo -ne "$g\t$s\t"
		grep $g $s/$s.gene_fpkm.tsv | cut -f2 | tr "\n" "\t"
		grep $g $s/$s.gene_fpkm.ruvg.tsv | cut -f2 | tr "\n" "\t"
		grep $g $s/$s.gene_tpm.tsv | cut -f2 | tr "\n" "\t"
		grep $g $s/$s.gene_tpm.ruvg.tsv | cut -f2
	done
done
