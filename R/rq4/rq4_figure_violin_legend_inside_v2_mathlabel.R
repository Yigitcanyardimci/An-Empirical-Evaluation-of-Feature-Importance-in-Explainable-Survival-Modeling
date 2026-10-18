# rq4_figure_violin_legend_inside_v2_mathlabel.R
#
# rq4_figure_violin_legend_inside_v2.R'nin BIREBIR AYNISI - TEK FARK:
# yatay eksen etiketi "TIVM" (duz metin) yerine makaledeki matematiksel
# gosterim \overline{TIV}_{\mathcal{M}} (plotmath: bar(TIV)[italic(M)]).
# Baska HICBIR sey (veri, renkler, alpha, dodge, tema, model sirasi,
# legend) degistirilmedi. Orijinal dosyalarin UZERINE YAZILMAZ, ayri
# dosya olarak kaydedilir.

setwd("~/Survival-XAI")
.libPaths(c("~/R/library", .libPaths()))
suppressMessages({
  library(ggplot2)
  library(dplyr)
  library(ggdist)
})

df <- read.csv("results/rq4/tivm_model_level.csv", stringsAsFactors = FALSE)

MODEL_ORDER <- c("Cox", "AORSF", "CForest", "CoxBoost", "CTree", "CV-GLMNet",
                  "GLMBoost", "GLMNet", "Penalized", "Ranger", "RSF", "XGBoost Cox")
df$model  <- factor(df$model, levels = rev(MODEL_ORDER))
df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

DODGE_W <- 0.9

p <- ggplot(df, aes(x = model, y = TIVM, fill = method, color = method)) +

  stat_halfeye(
    adjust = 0.7, width = 0.7, .width = 0, point_size = NA,
    position = position_dodge(width = DODGE_W),
    justification = -0.25, alpha = 0.40,
    slab_linewidth = 0.5
  ) +

  geom_boxplot(
    width = 0.14, outlier.shape = NA, alpha = 0.52, linewidth = 0.6,
    position = position_dodge(width = DODGE_W)
  ) +

  stat_dots(
    side = "bottom", justification = 1.15, scale = 0.55,
    position = position_dodge(width = DODGE_W),
    alpha = 0.60, shape = 16
  ) +

  scale_fill_manual(values = method_colors, name = NULL) +
  scale_color_manual(values = method_colors, name = NULL) +

  coord_flip() +

  labs(x = NULL, y = expression(bar(TIV)[italic(M)])) +

  theme_bw(base_size = 20) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position    = c(0.97, 0.97),
    legend.justification = c(1, 1),
    legend.direction   = "vertical",
    legend.background  = element_rect(fill = alpha("white", 0.9), color = "grey70", linewidth = 0.3),
    legend.margin      = margin(t = 4, r = 6, b = 4, l = 6),
    legend.key.size    = unit(0.6, "cm"),
    legend.spacing.y   = unit(0.05, "cm")
  )

dir.create("rq4/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("figures/rq4/figure_rq4_tivm_violin_legend_inside_v2_mathlabel.pdf", plot = p, width = 12, height = 9, dpi = 300, bg = "white")
ggsave("figures/rq4/figure_rq4_tivm_violin_legend_inside_v2_mathlabel.png", plot = p, width = 12, height = 9, dpi = 300, bg = "white")

cat("Kaydedildi: rq4/figures/figure_rq4_tivm_violin_legend_inside_v2_mathlabel.{pdf,png}\n")
cat("Orijinal figure_rq4_tivm_violin_legend_inside_v2.png/.pdf DOKUNULMADI.\n")
