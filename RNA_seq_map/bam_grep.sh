t=1
start_dir=$PWD

for s in $(cat sample.list)
do
	mkdir -p $s
	cd $s

	cat <<_EOS >bam_grep.sh
base_dir=\$PWD
work_dir=/scratch/kajitani/\$\$
mkdir -p \$work_dir

$start_dir/src/bam_read_name_grep read_name.list raw.bam | samtools view -b - > \$work_dir/$s.merged.bam

mv \$work_dir/* .
rm -r \$work_dir
_EOS
	
	qsub.sh bam_grep.sh $t a_$s

	cd $start_dir
done
