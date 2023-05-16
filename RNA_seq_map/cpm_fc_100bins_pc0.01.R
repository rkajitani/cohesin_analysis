library(ggplot2)
library(tidyr)
library(dplyr)
library(stringr)

df <- read.table("cpm_fc_100bins_pc0.01.R", header = T, sep = "\t")
 
y_max=0.2
y_min=-0.2
for (target_gene in c("protein", "lncRNA")) {
    plot_df <- df %>%
      filter(gene_type == target_gene) %>%
      mutate(sample = factor((sample), levels = c("NIPBLdep_C", "NIPBL_XRN2", "NIPBLdep_XRN2")))
    
    line_p <- ggplot(plot_df, aes(x = index, y = value, color = sample)) +
      geom_line() +
      facet_grid(. ~ len_category) +
      scale_y_continuous(limits = c(y_min, y_max), breaks = seq(-1, 1, 0.05)) +
      xlab("Position index (1-100)") +
      ylab("log2(fold-change)") +
      theme_bw() +
      theme(text=element_text(size=20))
    
      ggsave(plot=line_p, filename=sprintf("cpm_fc_100bins_pc0.01.%s.pdf", target_gene), width = 20, height = 5)
}
