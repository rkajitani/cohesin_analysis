t=12
gtf=/ref/Homo_sapiens.GRCh38.104.gtf
ref_fa=/ref/ref.fa
ref_fa_pri=/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
start_dir=$PWD

seqkit fx2tab -nli $ref_fa_pri >ref_len.tsv
perl -ane 'print(join("\t", ($F[0], $F[3] - 1, $F[4])), "\n") if ($F[2] eq "exon")' $gtf >exon_raw.bed
bedtools sort -i exon_raw.bed | bedtools merge -i - >exon.bed

for d in 10000
do
	./bed_downstream.py gene.bed ref_len.tsv ${d} >gene_down${d}_raw.bed
	bedtools subtract -A -a gene_down${d}_raw.bed -b exon.bed >gene_down${d}.bed

	for s in `cat sample.list`
	do
		mkdir -p $s
		cd $s

		cat <<_EOS >depth_base_gene_down${d}.sh
s=$s
d=$d
ref_fa=$ref_fa

_EOS

		cat <<'_EOS' >>depth_base_gene_down${d}.sh
/usr/bin/time samtools depth -aa -b ../gene_down${d}.bed ${s}.merged.bam >${s}.gene_depth_down${d}.tsv 2>samtools_depth_down${d}.log
/usr/bin/time ../src/depth_bed ${s}.gene_depth_down${d}.tsv ../gene_down${d}.bed $ref_fa >${s}.base_gene_down${d}.tsv 2>depth_bed.log

n_read=`cat n_mapped.txt`
../cpm_value_position_g.py $s.base_gene_down${d}.tsv $n_read >$s.base_down${d}_cpm.tsv
_EOS

		qsub.sh depth_base_gene_down${d}.sh $t s$s${d}

		cd $start_dir
	done
done
