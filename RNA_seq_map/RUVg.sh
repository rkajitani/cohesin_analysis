source activate bioconductor

Rscript --slave --vanilla RUVg.R >RUVg.log 2>&1
Rscript --slave --vanilla RUVg_tpm.R >RUVg_tpm.log 2>&1

for f in ercc_fpkm_gene_ruvg.tsv ercc_tpm_gene_ruvg.tsv
do
	perl -pne 's/^/Feature\t/ if ($. == 1)' $f >tmp.tsv
	mv tmp.tsv $f
done
