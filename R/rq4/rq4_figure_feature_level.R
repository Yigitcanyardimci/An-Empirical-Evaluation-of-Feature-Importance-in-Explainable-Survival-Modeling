# rq4_figure_feature_level.R
#
# DESTEKLEYICI / EK gorsel (ana makaleye otomatik eklenmez - kullanici
# talebi geregi). FI-AUC (=A_bar) ile TIV arasindaki iliskiyi feature
# duzeyinde gosterir. Ayni renk/tema dili (rq1+_plot.R) korunmustur.

setwd("~/Survival-XAI")
suppressMessages({
  library(ggplot2)
  library(dplyr)
})

df <- read.csv("results/rq4/tiv_feature_level.csv", stringsAsFactors = FALSE)
df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

p <- ggplot(df, aes(x = FI_AUC, y = TIV, color = method)) +
  geom_point(shape = 16, size = 1.6, alpha = 0.35) +
  facet_wrap(vars(method), nrow = 1) +
  scale_color_manual(values = method_colors, name = "") +
  scale_x_log10() +
  scale_y_log10() +
  labs(x = "FI-AUC (A_bar, log scale)", y = "TIV (log scale)") +
  theme_bw(base_size = 20) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position   = "none"
  )

dir.create("rq4/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("results/rq4/figure_rq4_tiv_feature_level.pdf", plot = p, width = 12, height = 6, dpi = 300, bg = "white")

cat("Ek gorsel kaydedildi: rq4/figures/figure_rq4_tiv_feature_level.pdf\n")
