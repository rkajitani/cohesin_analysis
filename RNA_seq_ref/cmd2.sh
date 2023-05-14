for c in `cat chr.list`
do
	seqkit grep -p $c Homo_sapiens.GRCh38.dna.primary_assembly.fa >sep/chr$c.fa
	samtools faidx sep/chr$c.fa
	perl -ane "print if (\$F[0] eq '$c')" Homo_sapiens.GRCh38.104.gtf >sep/chr$c.gtf
done
