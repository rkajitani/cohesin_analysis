ref_dir=/ref
start_dir=$PWD

for d in 10000
do
	mkdir -p fc_pos_vec_unbin
	cd fc_pos_vec_unbin

	for coh in NIPBL
	do
		for ckd in "" dep
		do
			for exo in C XRN2 EXOSC3
			do
				for p in 0.01
				do
					s=${coh}${ckd}_${exo}
					../fold_change_transcript_value_position_g.py ../${coh}_C/${coh}_C.base_tts${d}_cpm.tsv ../${s}/${s}.base_tts${d}_cpm.tsv $v $p >${s}.base_tts${d}_cpm.fc_pc$p.tsv &
				done
			done
		done
	done
	wait

	cd $start_dir


	for g in prot lnc
	do
		for s in `cat sample.list`
		do
			fgrep -f $ref_dir/${g}_gene.list $s/$s.base_tts${d}_cpm.tsv >$s/$s.base_tts${d}_cpm.$g.tsv &
		done
		wait

		echo -e "sample\tvalue_type\tindex\tvalue" >base_tts${d}_cpm.$g.mean_sd.tsv
		for s in `cat sample.list`
		do
			./mean_sd_transcript_value_position_pad.py $s/$s.base_tts${d}_cpm.$g.tsv $(expr 2 \* $d) | perl -pne "s/^/$s\t/" >>base_tts${d}_cpm.$g.mean_sd.tsv
		done


		mkdir -p fc_pos_vec_unbin
		cd fc_pos_vec_unbin

		for p in 0.01
		do
			for coh in NIPBL
			do
				for ckd in "" dep
				do
					for exo in C XRN2 EXOSC3
					do
						s=${coh}${ckd}_${exo}
						fgrep -f $ref_dir/${g}_gene.list ${s}.base_tts${d}_cpm.fc_pc$p.tsv >${s}.base_tts${d}_cpm.fc_pc$p.$g.tsv
					done
				done
			done
		done

		for p in 0.01
		do
			echo -e "sample\tvalue_type\tindex\tvalue" >base_tts${d}_cpm.fc_pc$p.$g.mean_sd_log2.tsv
			for coh in NIPBL
			do
				for ckd in "" dep
				do
					for exo in C XRN2 EXOSC3
					do
						s=${coh}${ckd}_${exo}
						../mean_sd_transcript_value_position_pad_log2.py ${s}.base_tts${d}_cpm.fc_pc$p.$g.tsv $(expr 2 \* $d) | perl -pne "s/^/${s}\t/" >>base_tts${d}_cpm.fc_pc$p.$g.mean_sd_log2.tsv
					done
				done
			done
		done

		cd $start_dir
	done
done


for d in 10000
do
	for p in 0.01
	do
		echo -e "sample\tindex\tvalue\tlen_category\tgene_type" >cpm_fc_tts${d}_pc${p}.tsv
		for g in prot lnc 
		do
			sed -e '1d' fc_pos_vec_unbin/base_tts${d}_cpm.fc_pc$p.$g.mean_sd_log2.tsv | perl -ane "print(join(\"\t\", (@F, $g)), \"\n\")" | \
				perl -pne 's/^NIP_/NIPBL_/g' | \
				perl -pne 's/^NIPdep_/NIPBLdep_/' | \
				perl -pne 's/(\s)prot(\s)/\1protein\2/' | \
				perl -pne 's/(\s)lnc(\s)/\1lncRNA\2/' | \
				perl -ane 'print if ($F[0] ne "NIPBL_C")' | \
				perl -ane 'print if ($F[1] eq "mean")' | \
				grep -v -e "^RAD" -e "_DOM3Z" -e "_EXOSC3" | \
				cut -f1,3- >>cpm_fc_tts${d}_pc${p}.tsv
		done
	done
done
