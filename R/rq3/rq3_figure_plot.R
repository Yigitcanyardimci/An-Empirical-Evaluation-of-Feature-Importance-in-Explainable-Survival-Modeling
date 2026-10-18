library(ggplot2)
library(dplyr)
library(tidyr)

# ── 1. Veri Hazırlığı ─────────────────────────────────────────
df <- read.csv("results/rq3/rq3_long.csv")  # DOSYA REPODA YOK - bkz README

# N değerlerini etiketli faktör yapma
df$N <- factor(df$N, 
               levels = c(15, 50, 100), 
               labels = c("15", "50", "100"))

# Uzun formata getirme ve her veri seti için modellerin ortalamasını alma
df_avg <- df %>%
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
  group_by(dataset, N, metric) %>%
  summarise(value = mean(value, na.rm = TRUE), .groups = "drop")

# ── 2. Whisker Uçları İçin Staple Koordinatları (Dikey Kutu) ───
staple_w <- 0.2  # Staple çizgisinin yatay genişliği

whisker_stats <- df_avg %>%
  group_by(N, metric) %>%
  summarise(
    q1  = quantile(value, 0.25, na.rm = TRUE),
    q3  = quantile(value, 0.75, na.rm = TRUE),
    iqr = IQR(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    wmin = q1 - 1.5 * iqr,
    wmax = q3 + 1.5 * iqr
  )

whisker_ends <- df_avg %>%
  left_join(whisker_stats, by = c("N", "metric")) %>%
  group_by(N, metric, wmin, wmax) %>%
  summarise(
    lower_end = min(value[value >= wmin], na.rm = TRUE),
    upper_end = max(value[value <= wmax], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    x_num = as.numeric(N),
    x_lo  = x_num - staple_w / 2,
    x_hi  = x_num + staple_w / 2
  )

# ── 3. Grafik ─────────────────────────────────────────────────
p <- ggplot(df_avg, aes(x = N, y = value)) +
  
  # Nokta dağılımı (Jitter)
  geom_jitter(width = 0.12, height = 0,
              shape = 16, size = 2,
              alpha = 0.45) +
  
  # Dikey kutu grafiği
  geom_boxplot(outlier.shape = NA,
               alpha     = 0.25,
               width     = 0.45,
               linewidth = 0.6) +
  
  # Alt whisker staple çizgisi (yatay segment)
  geom_segment(data = whisker_ends,
               aes(x = x_lo, xend = x_hi,
                   y = lower_end, yend = lower_end),
               linewidth = 0.7, inherit.aes = FALSE) +
  
  # Üst whisker staple çizgisi (yatay segment)
  geom_segment(data = whisker_ends,
               aes(x = x_lo, xend = x_hi,
                   y = upper_end, yend = upper_end),
               linewidth = 0.7, inherit.aes = FALSE) +
  
  # Metrik panelleri (dikey eksen serbest ölçekli)
  facet_wrap(vars(metric), scales = "free_y", nrow = 1) + 
  
  labs(x = "N", y = NULL) +
  
  theme_bw(base_size = 20) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "none"
  )

# ── 4. Kaydetme ───────────────────────────────────────────────
# ggsave("rq3_boxplot_theme.png", plot = p,
#        width = 14, height = 6, dpi = 300, bg = "white")

p