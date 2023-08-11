t=1
start_dir=$PWD

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	cat <<_EOS >count_strand.sh
$start_dir/bam_count_strand.py $s.star.Aligned.toTranscriptome.out.bam >strand_count.tsv
_EOS

	qsub.sh count_strand.sh $t s$s

	cd $start_dir
done
