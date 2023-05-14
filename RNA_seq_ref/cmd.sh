source activate deg_analysis_20210829

index_size=14

cat Homo_sapiens.GRCh38.dna.primary_assembly.fa ERCC92.fa >ref.fa
cat Homo_sapiens.GRCh38.104.gtf ERCC92.gtf >ref.gtf

/usr/bin/time STAR --runMode genomeGenerate --genomeSAindexNbases $index_size --genomeFastaFiles ref.fa --sjdbGTFfile ref.gtf --genomeDir STAR_ref >STAR_genomeGenerate.log 2>&1
/usr/bin/time rsem-prepare-reference --gtf ref.gtf ref.fa rsem_ref >rsem-prepare-reference.log 2>&1

#grep gene_name ref.gtf >tmp.gtf
#python2 /data1/kajitani/tools/GTFtools_0.8.0/gtftools.py -d ind_intron.bed tmp.gtf
#rm tmp.gtf
#
#./gtf_intron_info.py ref.gtf >intron_info.tsv
#perl -ane 'print if ($F[2] == 1)' intron_info.tsv | cut -f1 >intron_1st.list
#perl -ane 'print if ($F[2] == 1 and $F[1] <= 200)' intron_info.tsv | cut -f1 >intron_1st_d200.list
#
#./gtf_exon_info.py Homo_sapiens.GRCh38.104.gtf >exon_info.tsv
#perl -ane 'print if ($F[2] == 1)' exon_info.tsv | cut -f1 >exon_1st.list
#perl -ane 'print if ($F[2] == 1 and $F[1] <= 200)' exon_info.tsv | cut -f1 >exon_1st_d200.list

perl -ne '@F=split(/\t/, $_); print(join("\t", ($1, $F[4] - $F[3] + 1, $F[0], $F[6], $F[3] - 1, $F[4])), "\n") if ($F[2] eq "gene" and $F[8] =~ /gene_id\W+(\w+)/)'  Homo_sapiens.GRCh38.104.gtf >gene_info.tsv
perl -ne '@F=split(/\t/, $_); print(join("\t", ($1, $F[4] - $F[3] + 1, $F[0], $F[6], $F[3] - 1, $F[4])), "\n") if ($F[2] eq "transcript" and $F[8] =~ /transcript_id\W+(\w+)/)'  Homo_sapiens.GRCh38.104.gtf >tran_info.tsv

perl -ane 'print if ($F[2] eq "transcript")' ref.gtf | perl -ane '$_ =~ /gene_id (\S+) .*transcript_id (\S+) .*gene_name (\S+)/; print(join("\t", ($2, $1, $3, $F[0])), "\n")' | perl -pne 's/[";]//g' | sort -u >transcript_gene.tsv

cut -f1,3-6 tran_info.tsv >tran_pos.tsv
cut -f1,4-7 exon_info.tsv >exon_pos.tsv
cut -f1,4-7 intron_info.tsv >intron_pos.tsv
cat exon_pos.tsv intron_pos.tsv >exon_intron_pos.tsv

cut -f1,9 exon_info.tsv >exon_tran.tsv
cut -f1,9 intron_info.tsv >intron_tran.tsv
cat exon_tran.tsv intron_tran.tsv >exon_intron_tran.tsv

cut -f1-3 transcript_gene.tsv | sort -u  >tran_gene_name.tsv
cut -f2 exon_tran.tsv | sort | uniq -c | perl -ne 'print($2, "\t", $1, "\n") if (/(\d+)\s+(\S+)/)' > tran_n_exon.tsv
tsv_left_join.py tran_pos.tsv tran_gene_name.tsv 0 0 | cut -f1-5,7 | perl -pne 's/\t$/\t./' >tmp.tsv
tsv_left_join.py tmp.tsv tran_n_exon.tsv 0 0 >tran_info_joined.tsv
tsv_left_join.py transcript_gene.tsv tran_n_exon.tsv 0 0 | cut -f2,5 >tmp.tsv
tsv_group_max.py tmp.tsv 0 >gene_max_n_exon.tsv
rm tmp.tsv
tsv_left_join.py exon_tran.tsv tran_gene_name.tsv 1 0 | perl -ane 'print(join("\t", ($F[1], $F[0], @F[2..$#F])), "\n")' >exon_gene_name.tsv

#grep 'gene_biotype "rRNA"' Homo_sapiens.GRCh38.104.gtf  | perl -ane 'print($1, "\n") if ($F[2] eq "gene" and /gene_id\W+(\w+)/)' > rRNA_gene_id.list
#
#perl -ane 'print($F[0], "\n") if ($F[6] - $F[5] < 100)' exon_info.tsv >exon_under100.list
#perl -ane 'print($F[8], "\n") if ($F[6] - $F[5] < 100)' exon_info.tsv | sort -u >tran_exon_under100.list
#perl -ane 'print($F[0], "\n") if ($F[2] == 1 and $F[6] - $F[5] < 100)' exon_info.tsv >exon_1st_under100.list
#perl -ane 'print($F[8], "\n") if ($F[2] == 1 and $F[6] - $F[5] < 100)' exon_info.tsv | sort -u >tran_exon_1st_under100.list
