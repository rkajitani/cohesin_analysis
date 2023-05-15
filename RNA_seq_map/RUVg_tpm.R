library(RUVSeq)
#library(RColorBrewer)

for (f in c("gene")) {
  in_file <- sprintf("ercc_tpm_%s.tsv", f)
  out_file <- sprintf("ercc_tpm_%s_ruvg.tsv", f)
  
  df <- read.table(file=in_file, header=T, row.names = 1, sep = "\t", check.names = F)
  filter <- apply(df, 1, function(x) length(x[x>=0])>=0)
  filtered <- df[filter,]
  genes <- rownames(filtered)[grep("^ERCC", rownames(filtered), invert = T)]
  spikes <- rownames(filtered)[grep("^ERCC", rownames(filtered))]
  x <-  as.factor(c(
		"NIPBL_C",
		"NIPBL_XRN2",
		"NIPBL_EXOSC3",
		"NIPBLdep_C",
		"NIPBLdep_XRN2",
		"NIPBLdep_EXOSC3"
  ))
  set <- newSeqExpressionSet(as.matrix(filtered), phenoData = data.frame(x, row.names=colnames(filtered)))
  set1 <- RUVg(set, spikes, k=1)
#  colors <- rep("#888888", 14)
#  par(las=2, mar=c(12,4,1,1))
#  plotRLE(set, outline=FALSE, ylim=c(-0.2, 0.2), col=colors[x], cex=0.05)
#  plotRLE(set1, outline=FALSE, ylim=c(-0.2, 0.2), col=colors[x])
  
  norm_df <- data.frame(apply(normCounts(set1), c(1, 2), function(x) max(x, 0)), check.names = F)
  write.table(norm_df, file=out_file, sep="\t", quote=F)
} 
