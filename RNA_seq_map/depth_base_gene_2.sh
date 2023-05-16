source activate deg_analysis_20210829

v=100
ref_dir=/ref
start_dir=$PWD


for s in `cat sample.list`
do
	samtools flagstat $s/$s.merged.bam | head -n2 | perl -pne 'chomp; s/^(\d+).*/\1\t/' | perl -ane 'print($F[0] - $F[1], "\n")' >$s/n_mapped.txt
	n_read=`cat $s/n_mapped.txt`
	./cpm_value_position.py $s/$s.base_gene.v$v.tsv $n_read >$s/$s.base_cpm.v$v.tsv
done


mkdir -p fc_pos_vec_non_kd_div
cd fc_pos_vec_non_kd_div

for coh in NIPBL
do
	for ckd in "" dep
	do
		for exo in C XRN2 EXOSC3
		do
			for p in 0.01
			do
				../fold_change_transcript_value_position.py ../${coh}_C/${coh}_C.base_cpm.v$v.tsv ../${coh}${ckd}_${exo}/${coh}${ckd}_${exo}.base_cpm.v$v.tsv $v $p >${coh}${ckd}_${exo}.base_cpm.fc_pc$p.v$v.tsv &
			done
		done
	done
	wait
done

cd $start_dir


for g in prot lnc
do
	lower_th=0
	upper_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 25 --fmt "%d")
	perl -ane "print if (\$F[1] >= $lower_th and \$F[1] < $upper_th)" $ref_dir/${g}_gene_len.tsv | cut -f1 > ${g}_gene_len_Q1.list

	lower_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 25 --fmt "%d")
	upper_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 50 --fmt "%d")
	perl -ane "print if (\$F[1] >= $lower_th and \$F[1] < $upper_th)" $ref_dir/${g}_gene_len.tsv | cut -f1 > ${g}_gene_len_Q2.list

	lower_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 50 --fmt "%d")
	upper_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 75 --fmt "%d")
	perl -ane "print if (\$F[1] >= $lower_th and \$F[1] < $upper_th)" $ref_dir/${g}_gene_len.tsv | cut -f1 > ${g}_gene_len_Q3.list

	lower_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --percentile 75 --fmt "%d")
	upper_th=$(cut -f2 $ref_dir/${g}_gene_len.tsv | st --max --fmt "%d")
	perl -ane "print if (\$F[1] >= $lower_th and \$F[1] < $upper_th)" $ref_dir/${g}_gene_len.tsv | cut -f1 > ${g}_gene_len_Q4.list


	for Q in 1 2 3 4
	do
		echo -e "sample\tvalue_type\tindex\tvalue" >base_cpm.v$v.len_Q$Q.$g.mean_sd.tsv
		for s in `cat sample.list`
		do
			fgrep -f ${g}_gene_len_Q$Q.list $s/$s.base_cpm.v$v.tsv >$s/$s.base_cpm.v$v.len_Q$Q.$g.tsv
			./mean_sd_transcript_value_position.py $s/$s.base_cpm.v$v.len_Q$Q.$g.tsv $v | perl -pne "s/^/${s}\t/" >>base_cpm.v$v.len_Q$Q.$g.mean_sd.tsv
		done
	done

	echo -e "sample\tvalue_type\tindex\tvalue" >base_cpm.v$v.$g.mean_sd.tsv
	for s in `cat sample.list`
	do
		fgrep -f $ref_dir/${g}_gene.list $s/$s.base_cpm.v$v.tsv >$s/$s.base_cpm.v$v.$g.tsv
		./mean_sd_transcript_value_position.py $s/$s.base_cpm.v$v.$g.tsv $v | perl -pne "s/^/${s}\t/" >>base_cpm.v$v.$g.mean_sd.tsv
	done


	mkdir -p fc_pos_vec_non_kd_div
	cd fc_pos_vec_non_kd_div

	for Q in 1 2 3 4
	do
		for p in 0.01
		do
			for coh in NIPBL
			do
				for ckd in "" dep
				do
					for exo in C XRN2 EXOSC3
					do
						s=${coh}${ckd}_${exo}
						fgrep -f ../${g}_gene_len_Q$Q.list ${s}.base_cpm.fc_pc$p.v$v.tsv >${s}.base_cpm.fc_pc$p.v$v.len_Q$Q.$g.tsv
					done
				done
			done
		done
	done

	for Q in 1 2 3 4
	do
		for p in 0.01
		do
			echo -e "sample\tvalue_type\tindex\tvalue" >base_cpm.fc_pc$p.v$v.len_Q$Q.$g.mean_sd_log2.tsv
			for coh in NIPBL
			do
				for ckd in "" dep
				do
					for exo in C XRN2 EXOSC3
					do
						s=${coh}${ckd}_${exo}
						../mean_sd_transcript_value_position_log2.py ${s}.base_cpm.fc_pc$p.v$v.len_Q$Q.$g.tsv $v | perl -pne "s/^/${s}\t/" >>base_cpm.fc_pc$p.v$v.len_Q$Q.$g.mean_sd_log2.tsv
					done
				done
			done
		done
	done

	cd $start_dir
done


for p in 0.01
do
	echo -e "sample\tindex\tvalue\tlen_category\tgene_type" >cpm_fc_${v}bins_pc${p}.tsv
	for g in prot lnc 
	do
		for q in Q1 Q2 Q3 Q4
		do  
			sed -e '1d' fc_pos_vec_non_kd_div/base_cpm.fc_pc${p}.v${v}.len_${q}.${g}.mean_sd_log2.tsv | perl -ane "print(join(\"\t\", (@F, $q, $g)), \"\n\")" | \
				perl -pne 's/^NIP_/NIPBL_/g' | \
				perl -pne 's/^NIPdep_/NIPBLdep_/' | \
				perl -pne 's/(\s)prot(\s)/\1protein\2/' | \
				perl -pne 's/(\s)lnc(\s)/\1lncRNA\2/' | \
				perl -ane 'print if ($F[0] ne "NIPBL_C")' | \
				perl -ane 'print if ($F[1] eq "mean")' | \
				grep -v -e "^RAD" -e "_DOM3Z" -e "_EXOSC3" | \
				cut -f1,3- >>cpm_fc_${v}bins_pc${p}.tsv
		done
	done
done
