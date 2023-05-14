cut -f4 gene.bed >gene.list
fgrep -f gene.list Homo_sapiens.GRCh38.104.gtf >gene.gtf 
./gtf_outmost_tts_transcript.py gene.gtf >outmost_tts_transcript.tsv

gffread -g Homo_sapiens.GRCh38.dna.primary_assembly.fa -w transcript.fa tmp.gtf
cut -f1 outmost_tts_transcript.tsv >outmost_tts_transcript.list
seqkit grep -f outmost_tts_transcript.list transcript.fa >outmost_tts_transcript.fa
./fasta_find_polyA_motif.py outmost_tts_transcript.fa 35 AATAAA ATTAAA >outmost_tts_transcript_polyA.list
fgrep -f outmost_tts_transcript_polyA.list outmost_tts_transcript.tsv | cut -f2 | sort -u >gene_polyA.list
