# rq4_figure5.R
#
# Figure 5 (RQ4: Temporal Variability of Feature Importance).
# Gorsel dil dogrudan masaustundeki rq1+_plot.R (ana referans, renkler +
# genel tema) ve rq3_plot.R'den (boxplot + jitter + ozel "staple" whisker
# mekanigi) alinmistir. Yeni renk/tema secilmemistir.
#
# rq1+_plot.R'den alinanlar: method_colors (SurvSHAP="#2166ac", SurvPFI="#d73027"),
#   theme_bw(base_size=20), legend.position="bottom", panel.grid.minor blank.
# rq3_plot.R'den alinanlar: geom_jitter(shape=16, alpha=0.45), geom_boxplot
#   (outlier.shape=NA, alpha=0.25, linewidth=0.6), manuel staple-whisker
#   (geom_segment ile IQR-fence tabanli whisker uc noktalari), panel.grid
#   kategorik eksende kapali, dpi=300, bg="white".

setwd("~/Survival-XAI")
suppressMessages({
  library(ggplot2)
  library(dplyr)
})

df <- read.csv("results/rq4/tivm_model_level.csv", stringsAsFactors = FALSE)

# Projenin tum onceki gorsellerinde (advisor_results_csv paketi, 110 RQ2
# figurleri) kullanilan sabit/kanonik model sirasi. rq1+_plot.R / rq2+_plot.R /
# rq3_plot.R hicbirinde 12-modelli bir eksen olmadigi icin (hepsi dataset
# bazinda censoring-rate/N ekseni kullaniyor) buradan dogrudan alinabilecek
# bir model sirasi yok; bu nedenle projede daha once tutarli sekilde
# kullanilan siralama korunmustur.
MODEL_ORDER <- c("Cox", "AORSF", "CForest", "CoxBoost", "CTree", "CV-GLMNet",
                  "GLMBoost", "GLMNet", "Penalized", "Ranger", "RSF", "XGBoost Cox")
df$model  <- factor(df$model, levels = rev(MODEL_ORDER))  # rev: coord_flip sonrasi yukaridan asagiya doğru sira
df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

BOX_WIDTH   <- 0.7
DODGE_W     <- BOX_WIDTH
staple_w    <- 0.12

# ── Ozel "staple" whisker uc noktalari (rq3_plot.R'deki mantigin birebir
#    ayni sekilde model x method gruplarina uyarlanmis hali) ─────────────
whisker_stats <- df %>%
  group_by(model, method) %>%
  summarise(
    q1  = quantile(TIVM, 0.25, na.rm = TRUE),
    q3  = quantile(TIVM, 0.75, na.rm = TRUE),
    iqr = IQR(TIVM, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(wmin = q1 - 1.5 * iqr, wmax = q3 + 1.5 * iqr)

whisker_ends <- df %>%
  left_join(whisker_stats, by = c("model", "method")) %>%
  group_by(model, method, wmin, wmax) %>%
  summarise(
    lower_end = min(TIVM[TIVM >= wmin], na.rm = TRUE),
    upper_end = max(TIVM[TIVM <= wmax], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    x_num  = as.numeric(model) + ifelse(method == "SurvPFI", DODGE_W/4, -DODGE_W/4),
    x_lo   = x_num - staple_w / 2,
    x_hi   = x_num + staple_w / 2
  )

p <- ggplot(df, aes(x = model, y = TIVM, color = method, fill = method)) +

  geom_boxplot(outlier.shape = NA, alpha = 0.25, width = BOX_WIDTH,
               linewidth = 0.6, position = position_dodge(width = DODGE_W)) +

  geom_point(position = position_jitterdodge(jitter.width = 0.12, jitter.height = 0,
                                              dodge.width = DODGE_W),
             shape = 16, size = 2, alpha = 0.45) +

  geom_segment(data = whisker_ends,
               aes(x = x_lo, xend = x_hi, y = lower_end, yend = lower_end),
               linewidth = 0.7, inherit.aes = FALSE) +
  geom_segment(data = whisker_ends,
               aes(x = x_lo, xend = x_hi, y = upper_end, yend = upper_end),
               linewidth = 0.7, inherit.aes = FALSE) +

  scale_color_manual(values = method_colors, name = "") +
  scale_fill_manual(values = method_colors, name = "") +

  coord_flip() +

  labs(x = NULL, y = "TIVM (Temporal Importance Variability of the Model)") +

  theme_bw(base_size = 20) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position    = "bottom"
  )

dir.create("rq4/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("results/rq4/figure_rq4_tivm.pdf", plot = p, width = 10, height = 8, dpi = 300, bg = "white")
ggsave("results/rq4/figure_rq4_tivm.png", plot = p, width = 10, height = 8, dpi = 300, bg = "white")

cat("Figure 5 kaydedildi: rq4/figures/figure_rq4_tivm.pdf ve .png\n")
