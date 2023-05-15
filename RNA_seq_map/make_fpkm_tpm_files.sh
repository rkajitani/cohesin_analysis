source activate deg_analysis_20210829

start_dir=$PWD

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	cut -f1,7 ${s}.genes.results | sed -e '1d' >${s}.gene_fpkm.tsv
	cut -f1,6 ${s}.genes.results | sed -e '1d' >${s}.gene_tpm.tsv

	cd $start_dir
done


s=NIPBL_C
echo Feature >tmp
sed -e '1d' $s/$s.genes.results | cut -f1 | sort >>tmp
for s in `cat sample.list`
do
	echo $s >tmp2
	sed -e '1d' $s/$s.genes.results | sort | cut -f7 >>tmp2
	paste tmp tmp2 >tmp3
	mv tmp3 tmp
done
cat tmp >ercc_fpkm_gene.tsv


s=NIPBL_C
echo Feature >tmp
sed -e '1d' $s/$s.genes.results | cut -f1 | sort >>tmp
for s in `cat sample.list`
do
	echo $s >tmp2
	sed -e '1d' $s/$s.genes.results | sort | cut -f6 >>tmp2
	paste tmp tmp2 >tmp3
	mv tmp3 tmp
done
cat tmp >ercc_tpm_gene.tsv
