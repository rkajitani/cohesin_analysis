library(ggplot2)
library(tidyr)
library(dplyr)
library(stringr)

df <- read.table("cpm_fc_tts10000_pc0.01.tsv", header = T, sep = "\t")
 
y_max=0.2
y_min=-0.2
for (target_gene in c("protein", "lncRNA")) {
    plot_df <- df %>%
      mutate(index = index - 10000) %>%
      filter(gene_type == target_gene) %>%
      mutate(sample = factor((sample), levels = c("NIPBLdep_C", "NIPBL_XRN2", "NIPBLdep_XRN2")))
    
    line_p <- ggplot(plot_df, aes(x = index, y = value, color = sample)) +
      geom_line() +
      scale_y_continuous(limits = c(y_min, y_max), breaks = seq(-1, 1, 0.05)) +
      scale_x_continuous(limits = c(-10000, 10000), breaks = seq(-10000, 10000, 2000)) +
      xlab("Position (bp; 0, TTS)") +
      ylab("log2(fold-change)") +
      theme_bw() +
      theme(text=element_text(size=20))
    
      ggsave(plot=line_p, filename=sprintf("cpm_tts10000_pc0.01.%s.pdf", target_gene), width = 12, height = 5)
}
