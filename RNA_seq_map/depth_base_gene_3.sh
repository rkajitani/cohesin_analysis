t=1
gtf=/ref/Homo_sapiens.GRCh38.104.gtf
ref_fa=/ref/ref.fa
start_dir=$PWD

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	cat <<_EOS >depth_base_gene_3.sh
s=$s
ref_fa=$ref_fa

_EOS

	cat <<'_EOS' >>depth_base_gene_3.sh
/usr/bin/time ../src/depth_bed ${s}.gene_depth.tsv ../gene.bed $ref_fa >${s}.base_gene.tsv 2>depth_bed.log

n_read=`cat n_mapped.txt`
../cpm_value_position_g.py $s.base_gene.tsv $n_read >$s.base_cpm.tsv
_EOS

	qsub.sh depth_base_gene_3.sh $t s$s

	cd $start_dir
done
