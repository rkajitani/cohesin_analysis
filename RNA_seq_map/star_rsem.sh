t=12
read_dir=/reads/renamed
star_ref=/STAR_ref
rsem_ref=/rsem_ref
start_dir=$PWD

for s in `cat sample.list`
do
	mkdir -p $s
	cd $s

	cat <<_EOS >cmd.sh
source activate deg_analysis_20210829

base_dir=\$PWD
work_dir=/scratch/\$\$
mkdir -p \$work_dir
mv * \$work_dir
cd \$work_dir

ln -s $read_dir/$s.R1.fastq.gz R1.fastq.gz
ln -s $read_dir/$s.R2.fastq.gz R2.fastq.gz

/usr/bin/time STAR --genomeDir $star_ref --readFilesIn R1.fastq.gz R2.fastq.gz --readFilesCommand gunzip -c --outSAMtype BAM SortedByCoordinate --runThreadN $t --quantMode TranscriptomeSAM --outFileNamePrefix ${s}.star. >${s}.star.log 2>&1
/usr/bin/time rsem-calculate-expression --paired-end --bam ${s}.star.Aligned.toTranscriptome.out.bam --num-threads $t --no-bam-output $rsem_ref ${s} >${s}.rsem.log 2>&1
ln -s ${s}.star.Aligned.sortedByCoord.out.bam ${s}.merged.bam

cd \$base_dir
mv \$work_dir/* .
rm -r \$work_dir
_EOS

	qsub.sh cmd.sh $t s$s

	cd $start_dir
done
