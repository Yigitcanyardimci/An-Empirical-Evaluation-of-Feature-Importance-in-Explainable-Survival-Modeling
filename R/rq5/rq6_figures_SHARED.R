# rq6_figures.R
#
# RQ6 icin 3 gorsel. Hicbir yeniden hesaplama yok - sadece rq6/data/
# altinda zaten uretilmis CSV'ler okunur. Renkler/tema rq1+_plot.R ve
# RQ4/RQ5 script'lerinden AYNEN alinir (SurvSHAP=#2166ac, SurvPFI=#d73027).

setwd("~/Survival-XAI")
suppressMessages({
  library(ggplot2)
  library(dplyr)
  library(patchwork)
})

MODEL_ORDER <- c("Cox", "AORSF", "CForest", "CoxBoost", "CTree", "CV-GLMNet",
                  "GLMBoost", "GLMNet", "Penalized", "Ranger", "RSF", "XGBoost Cox")
method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

dir.create("rq6/figures", recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# FIGURE: censoring rate vs TIVM (facet ~ model)
# =============================================================================
tivm_df <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_censoring_tivm.csv", stringsAsFactors = FALSE)
tivm_df$model  <- factor(tivm_df$model, levels = MODEL_ORDER)
tivm_df$method <- factor(tivm_df$method, levels = c("SurvSHAP", "SurvPFI"))

base_theme <- theme_bw(base_size = 20) +
  theme(
    panel.grid.minor = element_blank(),
    strip.background  = element_rect(fill = "grey92", color = NA),
    strip.text        = element_text(size = 12, face = "bold"),
    axis.text         = element_text(size = 10),
    legend.position   = "bottom"
  )

p1 <- ggplot(tivm_df, aes(x = censoring_rate, y = TIVM, color = method)) +
  geom_point(shape = 16, size = 1.4, alpha = 0.5) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 0.6) +
  facet_wrap(vars(model), scales = "free_y", ncol = 4) +
  scale_color_manual(values = method_colors, name = "") +
  scale_x_continuous(breaks = seq(20, 100, by = 20)) +
  labs(x = "Censoring Rate (%)", y = "TIVM") +
  base_theme

ggsave("results/additional_analyses/censoring_tivm_relationship/figure_rq6_censoring_tivm.pdf", plot = p1, width = 14, height = 11, dpi = 300, bg = "white")
ggsave("results/additional_analyses/censoring_tivm_relationship/figure_rq6_censoring_tivm.png", plot = p1, width = 14, height = 11, dpi = 300, bg = "white")
cat("figure_rq6_censoring_tivm kaydedildi\n")

# =============================================================================
# FIGURE: dumbbell - model x rho (SurvSHAP vs SurvPFI, TIVM correlation)
# =============================================================================
rho_df <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_tivm_correlations.csv", stringsAsFactors = FALSE)
rho_df$model <- factor(rho_df$model, levels = rev(MODEL_ORDER))
rho_df$method <- factor(rho_df$method, levels = c("SurvSHAP", "SurvPFI"))

rho_wide <- rho_df %>%
  select(model, method, spearman_rho) %>%
  tidyr::pivot_wider(names_from = method, values_from = spearman_rho)

p2 <- ggplot() +
  geom_vline(xintercept = 0, color = "grey20", linewidth = 0.6) +
  geom_segment(data = rho_wide, aes(x = SurvSHAP, xend = SurvPFI, y = model, yend = model),
               color = "grey60", linewidth = 0.7) +
  geom_point(data = rho_df, aes(x = spearman_rho, y = model, color = method),
             size = 4.2, alpha = 0.9) +
  scale_color_manual(values = method_colors, name = "") +
  scale_x_continuous(limits = c(-0.6, 0.6), breaks = seq(-0.5, 0.5, by = 0.25)) +
  labs(x = expression("Spearman "*rho*"(Censoring Rate, TIVM)"), y = NULL) +
  theme_bw(base_size = 20) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position    = c(0.98, 0.98),
    legend.justification = c(1, 1),
    legend.background  = element_rect(fill = alpha("white", 0.9), color = "grey70", linewidth = 0.3),
    legend.key.size    = unit(0.5, "cm")
  )

ggsave("results/additional_analyses/censoring_tivm_relationship/figure_rq6_censoring_tivm_rho.pdf", plot = p2, width = 9, height = 7, dpi = 300, bg = "white")
ggsave("results/additional_analyses/censoring_tivm_relationship/figure_rq6_censoring_tivm_rho.png", plot = p2, width = 9, height = 7, dpi = 300, bg = "white")
cat("figure_rq6_censoring_tivm_rho kaydedildi\n")

# =============================================================================
# FIGURE: censoring rate vs agreement metrikleri (3 panel: A/B/C)
# =============================================================================
agree_df <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)

panel_theme <- theme_bw(base_size = 18) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position   = "none"
  )

mk_panel <- function(metric_name, ylab) {
  sub <- agree_df %>% filter(metric == metric_name)
  ggplot(sub, aes(x = censoring_rate, y = value)) +
    geom_point(shape = 16, size = 1.3, alpha = 0.35, color = "grey30") +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 0.6, color = "black") +
    scale_x_continuous(breaks = seq(20, 100, by = 40)) +
    labs(x = "Censoring Rate (%)", y = ylab) +
    panel_theme
}

pA <- mk_panel("weighted_tau", "weighted_tau")
pB <- mk_panel("overlap_at_3", "overlap_at_3")
pC <- mk_panel("symmetric_kl", "symmetric_kl")

p3 <- (pA + pB + pC) + plot_layout(ncol = 3) + plot_annotation(tag_levels = "A")

ggsave("results/rq5/figure_rq6_censoring_agreement.pdf", plot = p3, width = 15, height = 5.5, dpi = 300, bg = "white")
ggsave("results/rq5/figure_rq6_censoring_agreement.png", plot = p3, width = 15, height = 5.5, dpi = 300, bg = "white")
cat("figure_rq6_censoring_agreement kaydedildi\n")

cat("\nBITTI\n")
