source activate deg_analysis_20210829

t=12
v=100
gtf=/ref/Homo_sapiens.GRCh38.104.gtf
ref_fa=/ref/ref.fa
start_dir=$PWD

perl -ane 'print(join("\t", ($F[0], $F[3] - 1, $F[4], $1, ".", $F[6])), "\n") if ($F[2] eq "gene" and /gene_id "([a-zA-Z0-9]+)"/)' $gtf >gene.bed

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	cat <<_EOS >depth_base_gene.sh
/usr/bin/time samtools depth -aa -b ../gene.bed ${s}.merged.bam >${s}.gene_depth.tsv 2>samtools_depth.log
/usr/bin/time ../src/depth_bed_bin ${s}.gene_depth.tsv ../gene.bed $ref_fa $v >${s}.base_gene.v$v.tsv 2>depth_bed_bin.log
_EOS

	qsub.sh depth_base_gene.sh $t s$s

	cd $start_dir
done
