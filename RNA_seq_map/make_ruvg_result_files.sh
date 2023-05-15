for m in fpkm tpm
do
	for f in gene
	do
		datamash transpose < ercc_${m}_${f}_ruvg.tsv >tmp

		for s in `cat sample.list`
		do
			mkdir -p $s
			head -n1 tmp >tmp2
			grep "^$s" tmp >>tmp2
			datamash transpose < tmp2 | sed -e '1d' >$s/$s.${f}_${m}.ruvg.tsv
		done

		rm tmp tmp2
	done
done
