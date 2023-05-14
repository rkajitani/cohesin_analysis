gtf=Homo_sapiens.GRCh38.104.gtf

perl -ane 'print(join("\t", ($F[0], $F[3] - 1, $F[4], $1, ".", $F[6])), "\n") if ($F[2] eq "gene" and /gene_id "([a-zA-Z0-9]+)"/)' $gtf >gene.bed
perl -ane 'print($F[3], "\t", $F[2] - $F[1], "\n")' gene.bed >gene_len.tsv
cut -f2 gene_len.tsv | st --all >gene_len_stats.tsv
perl -ne '@F=split(/\t/, $_); print($1, "\n") if ($F[2] eq "gene" and $F[8] =~ /gene_biotype "(\w+)"/)' Homo_sapiens.GRCh38.104.gtf | sort | uniq -c >gene_biotype_count.txt

perl -ne '@F=split(/\t/, $_); print if ($F[2] eq "gene" and $F[8] =~ /gene_biotype "(\w+)"/ and $1 eq "protein_coding")' Homo_sapiens.GRCh38.104.gtf |
	perl -ne '@F=split(/\t/, $_); print($1, "\n") if ($F[8] =~ /gene_id "(\w+)"/)' |
	sort -u >prot_gene.list

perl -ne '@F=split(/\t/, $_); print if ($F[2] eq "gene" and $F[8] =~ /gene_biotype "(\w+)"/ and $1 eq "lncRNA")' Homo_sapiens.GRCh38.104.gtf |
	perl -ne '@F=split(/\t/, $_); print($1, "\n") if ($F[8] =~ /gene_id "(\w+)"/)' |
	sort -u >lnc_gene.list

for g in prot lnc
do
	fgrep -f ${g}_gene.list gene_len.tsv >${g}_gene_len.tsv
	cut -f2 ${g}_gene_len.tsv | st --all >${g}_gene_len_stats.tsv
done
