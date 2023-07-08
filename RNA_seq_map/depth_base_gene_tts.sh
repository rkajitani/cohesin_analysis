t=1
gtf=/ref/Homo_sapiens.GRCh38.104.gtf
ref_fa=/ref/ref.fa
start_dir=$PWD

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	for d in 10000
	do
		cat <<_EOS >depth_base_gene_tts${d}.sh
s=$s
d=$d
ref_fa=$ref_fa

_EOS

		cat <<'_EOS' >>depth_base_gene_tts${d}.sh
perl -pne 's/^(\S+)_down/\1/g' ${s}.base_down${d}_cpm.tsv >tmp.tsv
../join_tsv_fixed_len.py ${s}.base_cpm.tsv tmp.tsv ${d} >${s}.base_tts${d}_cpm.tsv
rm tmp.tsv
_EOS

		qsub.sh depth_base_gene_tts${d}.sh $t s$s
	done

	cd $start_dir
done
