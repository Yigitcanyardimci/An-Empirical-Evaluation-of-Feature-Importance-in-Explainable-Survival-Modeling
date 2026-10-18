library(ggplot2)
library(dplyr)
library(tidyr)
library(ggrepel)

# ── 1. Sansür Oranları Eşlemesi ───────────────────────────────
survival_datasets <- data.frame(
  Dataset = c(
    "acath", "aids2", "breast", "burn", "cancer", "cgd", "colon", "csl", 
    "d_oropha_rec", "dataDIVAT1", "dataDIVAT3", "dialysis", "e1684", "epileptic", 
    "flchain", "Framingham", "FRTCS", "GBSG2", "grace", "LeukSurv", "melanoma", 
    "nwtco", "ova", "pbc", "Pbc3", "prostate", "prostateSurvival", "rdata", 
    "retinopathy", "Rossi", "rott2", "stagec", "TRACE", "veteran", "whas500", "zinc"
  ),
  Censoring_Rate_Percent = c(
    34.0, 38.0, 74.0, 68.8, 27.8, 65.6, 51.6, 89.1, 27.6, 83.6, 
    94.4, 76.4, 31.0, 82.8, 69.9, 68.5, 96.6, 56.4, 67.6, 15.7, 
    72.2, 85.8, 25.7, 59.9, 82.9, 28.8, 94.4, 47.4, 60.7, 91.9, 
    57.3, 62.5, 49.0, 6.6, 61.8, 81.2
  ),
  stringsAsFactors = FALSE
)

censor_tbl <- survival_datasets %>%
  select(dataset = Dataset, censor_rate = Censoring_Rate_Percent)

# ── 2. RQ1 Veri Hazırlığı ─────────────────────────────────────
df <- read.csv("results/rq1/rq1_long.csv")  # SEMA FARKLI (tau/top3/kl vs weighted_tau/overlap_at_3/symmetric_kl) - bkz README

df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

# Uzun format: Her veri seti + yöntem + metrik ortalaması
df_long <- df %>%
  pivot_longer(cols = c(tau, top3, kl),
               names_to  = "metric",
               values_to = "value") %>%
  mutate(
    metric = recode(metric,
                    tau  = "Weighted Kendall's Tau (↑)",
                    top3 = "Top-3 Overlap (↑)",
                    kl   = "Symmetric KL Divergence (↓)"
    ),
    metric = factor(metric, levels = c(
      "Weighted Kendall's Tau (↑)",
      "Top-3 Overlap (↑)",
      "Symmetric KL Divergence (↓)"
    ))
  ) %>%
  group_by(dataset, method, metric) %>%
  summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop") %>%
  inner_join(censor_tbl, by = "dataset")

# ── 3. Noktaları Birleştiren Çizgiler ve Orta Noktalar ─────────
df_pairs <- df_long %>%
  select(dataset, censor_rate, metric, method, mean_value) %>%
  pivot_wider(names_from = method, values_from = mean_value) %>%
  mutate(y_mid = (SurvSHAP + SurvPFI) / 2)

# ── 4. Renkler ────────────────────────────────────────────────
method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

# ── 5. Grafik ─────────────────────────────────────────────────
p_rq1_trend <- ggplot(df_long, aes(x = censor_rate, y = mean_value, 
                                   color = method, fill = method)) +
  
  # Aynı veri setine ait iki noktayı bağlayan dikey çizgi
  geom_segment(data = df_pairs,
               aes(x = censor_rate, xend = censor_rate,
                   y = SurvSHAP, yend = SurvPFI),
               color = "grey65", linewidth = 0.6, linetype = "solid",
               inherit.aes = FALSE) +
  
  # Veri seti noktaları:
  # shape = 21 (dolgulu daire) + alpha (şeffaf dolgu) + stroke (kenar çizgisi)
  # Bu sayede üst üste binen noktalar birbirini kapatmaz, renkleri karışır ve sınırları görünür kalır
  geom_point(shape = 21, size = 3.5, stroke = 0.6, alpha = 0.55) +
  
  # Veri seti isimleri (orta noktaya hizalı)
  geom_text_repel(data = df_pairs,
                  aes(x = censor_rate, y = y_mid, label = dataset), 
                  size = 3.2, 
                  max.overlaps = 8, 
                  color = "grey35", 
                  family = "Courier",
                  inherit.aes = FALSE) +
  
  # Doğrusal regresyon çizgisi (lm) ve %95 güven bandı
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, 
              alpha = 0.15, linewidth = 0.9) +
  
  # Metrik panelleri (serbest dikey ölçek)
  facet_wrap(vars(metric), scales = "free_y", nrow = 1) +
  
  scale_color_manual(values = method_colors, name = "") +
  scale_fill_manual(values = method_colors, name = "") +
  
  scale_x_continuous(labels = function(x) paste0(x), 
                     breaks = seq(0, 100, by = 20),
                     limits = c(10, 100)) +
  
  labs(
    x = "Censoring Rate (%)",
    y = "Mean Agreement Across Models"
  ) +
  
  theme_bw(base_size = 20) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position  = "bottom"
  )

# ── 6. Görüntüleme & Kaydetme ─────────────────────────────────
# ggsave("rq1_censoring_paired_alpha.png", plot = p_rq1_trend, width = 15, height = 6, dpi = 300, bg = "white")

p_rq1_trend