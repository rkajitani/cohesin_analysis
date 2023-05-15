start_dir=$PWD
read_dir=""
t=6

for s in `cat sample.list`
do
 	mkdir -p $s
done

for i in 1 2
do
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
	ln -s $read_dir/_${i}.fastq.gz /R${i}.fastq.gz
done


mkdir -p renamed

for s in `cat sample.list`
do
	cd $s

	cat <<_EOS >cmd.sh
t=$t

_EOS

	cat <<'_EOS' >>cmd.sh
source activate deg_analysis_20210829

base_dir=$PWD
work_dir=/scratch/$$
mkdir -p $work_dir
cd $work_dir

fastp -w $t -i $base_dir/R1.fastq.gz -I $base_dir/R2.fastq.gz -o R1.trim.fastq.gz -O R2.trim.fastq.gz >fastp.log 2>&1

zcat $base_dir/R?.fastq.gz | seqkit stats -T >raw.stat &
zcat R?.trim.fastq.gz | seqkit stats -T >trim.stat &
wait

cd $base_dir
mv $work_dir/* .
rm -r $work_dir

ln -s ../$s/R1.trim.fastq.gz ../renamed/$s.R1.fastq.gz
ln -s ../$s/R2.trim.fastq.gz ../renamed/$s.R2.fastq.gz
_EOS
	
	qsub.sh cmd.sh $t $s

	cd $start_dir
done
