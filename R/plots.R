# plots.R
#
# RQ1-RQ5 grafik/analiz kodlarinin birlestirilmis hali. Her bolum, daha
# once ayri dosyalar halinde bulunan (R/rq3/, R/rq4/, R/rq5/,
# R/additional_analyses/censoring_exploratory/) script'lerin BIREBIR AYNISI,
# sadece bagimsiz calistirilabilir birer fonksiyona sarilmistir - hicbir
# hesaplama, renk, tema veya mantik DEGISTIRILMEMISTIR. Her fonksiyon kendi
# scope'unda calistigi icin degisken isimleri (df, p, method_colors vb.)
# bolumler arasinda CAKISMAZ.
#
# Eksik kod notu: RQ1 ve RQ2 icin ayri bir grafik-uretim script'i hicbir
# yerde (VM, GitHub, masaustu) bulunamadi - bu dosyada da UYDURULMADI.
# Sadece RQ1/RQ2 sonuclarini censoring rate ile iliskilendiren KESIFSEL
# (ana RQ1/RQ2 koduyla KARISTIRILMAMASI gereken) iki script asagida ayri
# bir baslik altinda korunmustur.
#
# Kullanim: her fonksiyon tek basina cagrilabilir, orn. rq4_figure5_boxplot()

# ── Ortak kutuphaneler (tum bolumlerin kullandigi kutuphanelerin birlesimi) ──
suppressMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(ggrepel)
  library(patchwork)
})
# Asagidaki paketler sadece ilgili fonksiyonlar cagrildiginda gerekir
# (ggdist: rq4_figure_violin_mathlabel; ggstatsplot/ggside: rq5_ggscatterstats_refined).
# Kurulu degillerse projenin kisisel kutuphane yolu eklenir:
#   .libPaths(c("~/R/library", .libPaths()))


# =============================================================================
# RQ3 - Numerical Stability (N=15/50/100)
# =============================================================================

#' Figure (RQ3): N=15/50/100 boxplot+jitter+staple-whisker, 3 metrik paneli.
#' KAYNAK: R/rq3/rq3_figure_plot.R
#' EKSIK VERI: "results/rq3/rq3_long.csv" repoda YOK - bu fonksiyon calismaz.
rq3_figure_plot <- function() {
  setwd("~/Survival-XAI")

  df <- read.csv("results/rq3/rq3_long.csv")  # DOSYA REPODA YOK - bkz README

  df$N <- factor(df$N,
                 levels = c(15, 50, 100),
                 labels = c("15", "50", "100"))

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

  staple_w <- 0.2

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

  p <- ggplot(df_avg, aes(x = N, y = value)) +
    geom_jitter(width = 0.12, height = 0,
                shape = 16, size = 2,
                alpha = 0.45) +
    geom_boxplot(outlier.shape = NA,
                 alpha     = 0.25,
                 width     = 0.45,
                 linewidth = 0.6) +
    geom_segment(data = whisker_ends,
                 aes(x = x_lo, xend = x_hi,
                     y = lower_end, yend = lower_end),
                 linewidth = 0.7, inherit.aes = FALSE) +
    geom_segment(data = whisker_ends,
                 aes(x = x_lo, xend = x_hi,
                     y = upper_end, yend = upper_end),
                 linewidth = 0.7, inherit.aes = FALSE) +
    facet_wrap(vars(metric), scales = "free_y", nrow = 1) +
    labs(x = "N", y = NULL) +
    theme_bw(base_size = 20) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      legend.position    = "none"
    )

  # ggsave("rq3_boxplot_theme.png", plot = p, width = 14, height = 6, dpi = 300, bg = "white")

  p
}


# =============================================================================
# RQ4 - Temporal Variability (TIVM)
# =============================================================================

#' RQ4 veri uretimi: vimp_summary.csv / shap_summary_n100.csv dosyalarindan
#' TIVM (model-level) ve TIV (feature-level) tablolarini derler.
#' KAYNAK: R/rq4/rq4_build_data.R
#' Hicbir model yeniden egitilmez, hicbir SurvSHAP/SurvPFI yeniden hesaplanmaz.
rq4_build_data <- function() {
  setwd("~/Survival-XAI")
  suppressMessages(library(dplyr))

  MODEL_MAP <- c(
    "Cox"         = "cox",
    "AORSF"       = "aorsf",
    "CForest"     = "cforest",
    "CoxBoost"    = "coxboost",
    "CTree"       = "ctree",
    "CV-GLMNet"   = "cv_glmnet",
    "GLMBoost"    = "glmboost",
    "GLMNet"      = "glmnet",
    "Penalized"   = "penalized",
    "Ranger"      = "ranger",
    "RSF"         = "rfsrc",
    "XGBoost Cox" = "xgboost_cox"
  )

  DATASETS <- c("FRTCS","Framingham","GBSG2","LeukSurv","Rossi","TRACE","acath","aids2",
                "colon","csl","dataDIVAT1","dataDIVAT3","dialysis","epileptic","grace",
                "nwtco","ova","prostate","prostateSurvival","rdata","retinopathy","rott2",
                "whas500","zinc")

  calculate_TIVM <- function(summary_df) {
    sum(summary_df$R_bar * summary_df$TIV, na.rm = TRUE)
  }

  tivm_rows    <- list()
  feature_rows <- list()
  missing_log  <- list()
  idx_t <- 1; idx_f <- 1; idx_m <- 1

  for (model_display in names(MODEL_MAP)) {
    model_folder <- MODEL_MAP[[model_display]]
    for (ds in DATASETS) {
      dir_path <- file.path("results", model_folder, ds)

      pfi_path <- file.path(dir_path, "vimp_summary.csv")
      if (file.exists(pfi_path)) {
        pfi_df <- read.csv(pfi_path, stringsAsFactors = FALSE)
        req_cols <- c("variable","A_hat","A_bar","TIV","R_bar")
        if (all(req_cols %in% names(pfi_df)) && nrow(pfi_df) > 0) {
          tivm_val <- calculate_TIVM(pfi_df)
          tivm_rows[[idx_t]] <- data.frame(dataset = ds, model = model_display,
                                            method = "SurvPFI", TIVM = tivm_val,
                                            n_features = nrow(pfi_df))
          idx_t <- idx_t + 1
          for (i in seq_len(nrow(pfi_df))) {
            feature_rows[[idx_f]] <- data.frame(
              dataset = ds, model = model_display, method = "SurvPFI",
              feature = pfi_df$variable[i], FI_AUC = pfi_df$A_bar[i],
              R_bar = pfi_df$R_bar[i], TIV = pfi_df$TIV[i])
            idx_f <- idx_f + 1
          }
        } else {
          missing_log[[idx_m]] <- data.frame(dataset = ds, model = model_display,
                                              method = "SurvPFI", issue = "eksik_sutun_veya_bos")
          idx_m <- idx_m + 1
        }
      } else {
        missing_log[[idx_m]] <- data.frame(dataset = ds, model = model_display,
                                            method = "SurvPFI", issue = "dosya_yok:vimp_summary.csv")
        idx_m <- idx_m + 1
      }

      shap_path <- file.path(dir_path, "shap_summary_n100.csv")
      if (file.exists(shap_path)) {
        shap_df <- read.csv(shap_path, stringsAsFactors = FALSE)
        req_cols <- c("variable","A_hat","A_bar","TIV","R_bar")
        if (all(req_cols %in% names(shap_df)) && nrow(shap_df) > 0) {
          tivm_val <- calculate_TIVM(shap_df)
          tivm_rows[[idx_t]] <- data.frame(dataset = ds, model = model_display,
                                            method = "SurvSHAP", TIVM = tivm_val,
                                            n_features = nrow(shap_df))
          idx_t <- idx_t + 1
          for (i in seq_len(nrow(shap_df))) {
            feature_rows[[idx_f]] <- data.frame(
              dataset = ds, model = model_display, method = "SurvSHAP",
              feature = shap_df$variable[i], FI_AUC = shap_df$A_bar[i],
              R_bar = shap_df$R_bar[i], TIV = shap_df$TIV[i])
            idx_f <- idx_f + 1
          }
        } else {
          missing_log[[idx_m]] <- data.frame(dataset = ds, model = model_display,
                                              method = "SurvSHAP", issue = "eksik_sutun_veya_bos")
          idx_m <- idx_m + 1
        }
      } else {
        missing_log[[idx_m]] <- data.frame(dataset = ds, model = model_display,
                                            method = "SurvSHAP", issue = "dosya_yok:shap_summary_n100.csv")
        idx_m <- idx_m + 1
      }
    }
  }

  tivm_df    <- do.call(rbind, tivm_rows)
  feature_df <- do.call(rbind, feature_rows)
  missing_df <- if (length(missing_log) > 0) do.call(rbind, missing_log) else
    data.frame(dataset=character(0), model=character(0), method=character(0), issue=character(0))

  dir.create("rq4/data", recursive = TRUE, showWarnings = FALSE)
  dir.create("rq4/diagnostics", recursive = TRUE, showWarnings = FALSE)

  write.csv(tivm_df,    "results/rq4/tivm_model_level.csv", row.names = FALSE)
  write.csv(feature_df, "results/rq4/tiv_feature_level.csv", row.names = FALSE)
  write.csv(missing_df, "results/rq4/rq4_missing_combinations.csv", row.names = FALSE)

  cat("=== OZET ===\n")
  cat("tivm_model_level.csv satir sayisi:", nrow(tivm_df),
      "(beklenen: 12 model x 24 dataset x 2 method =", 12*24*2, ")\n")
  cat("tiv_feature_level.csv satir sayisi:", nrow(feature_df), "\n")
  cat("Eksik/sorunlu kombinasyon sayisi:", nrow(missing_df), "\n")
  if (nrow(missing_df) > 0) {
    cat("\nEksik kombinasyonlar:\n")
    print(missing_df)
  }

  cat("\n=== method x model bazinda TIVM ozet istatistikleri ===\n")
  summary_stats <- tivm_df %>%
    group_by(model, method) %>%
    summarise(n = n(), mean_TIVM = mean(TIVM), sd_TIVM = sd(TIVM),
              median_TIVM = median(TIVM), .groups = "drop")
  print(as.data.frame(summary_stats))

  cat("\nBITTI\n")
  invisible(list(tivm = tivm_df, feature = feature_df, missing = missing_df))
}

#' Figure (RQ4, eski/ilk versiyon): TIVM boxplot+jitter+staple-whisker.
#' KAYNAK: R/rq4/rq4_figure5.R
rq4_figure5_boxplot <- function() {
  setwd("~/Survival-XAI")
  suppressMessages({
    library(ggplot2)
    library(dplyr)
  })

  df <- read.csv("results/rq4/tivm_model_level.csv", stringsAsFactors = FALSE)

  MODEL_ORDER <- c("Cox", "AORSF", "CForest", "CoxBoost", "CTree", "CV-GLMNet",
                    "GLMBoost", "GLMNet", "Penalized", "Ranger", "RSF", "XGBoost Cox")
  df$model  <- factor(df$model, levels = rev(MODEL_ORDER))
  df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

  method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

  BOX_WIDTH   <- 0.7
  DODGE_W     <- BOX_WIDTH
  staple_w    <- 0.12

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
  p
}

#' Figure (RQ4, GUNCEL/MAKALE versiyonu): raincloud (half-eye + box + dots),
#' matematiksel eksen etiketi \overline{TIV}_M.
#' KAYNAK: R/rq4/rq4_figure_violin_legend_inside_v2_mathlabel.R
rq4_figure_violin_mathlabel <- function() {
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
  p
}

#' Figure (RQ4, destekleyici/ek): FI-AUC vs TIV, feature duzeyinde.
#' KAYNAK: R/rq4/rq4_figure_feature_level.R
rq4_figure_feature_level <- function() {
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
  p
}


# =============================================================================
# RQ5 - Censoring Rate vs SurvSHAP/SurvPFI Agreement
# =============================================================================

#' RQ5 veri uretimi: 24 dataset icin censoring rate (ham task verisinden
#' dogrulanmis). KAYNAK: R/rq5/rq6_censoring_rates.R
rq5_censoring_rates <- function() {
  setwd("~/Survival-XAI")
  suppressMessages({
    source("R/01_install_packages.R")
    source("R/02_import_datasets.R")
    source("R/03_modeling.R")
  })

  existing_pct <- c(
    acath = 34.0, aids2 = 38.0, breast = 74.0, burn = 68.8, cancer = 27.8,
    cgd = 65.6, colon = 51.6, csl = 89.1, d_oropha_rec = 27.6, dataDIVAT1 = 83.6,
    dataDIVAT3 = 94.4, dialysis = 76.4, e1684 = 31.0, epileptic = 82.8,
    flchain = 69.9, Framingham = 68.5, FRTCS = 96.6, GBSG2 = 56.4, grace = 67.6,
    LeukSurv = 15.7, melanoma = 72.2, nwtco = 85.8, ova = 25.7, pbc = 59.9,
    Pbc3 = 82.9, prostate = 28.8, prostateSurvival = 94.4, rdata = 47.4,
    retinopathy = 60.7, Rossi = 91.9, rott2 = 57.3, stagec = 62.5, TRACE = 49.0,
    veteran = 6.6, whas500 = 61.8, zinc = 81.2
  )

  DATASETS <- c("FRTCS","Framingham","GBSG2","LeukSurv","Rossi","TRACE","acath","aids2",
                "colon","csl","dataDIVAT1","dataDIVAT3","dialysis","epileptic","grace",
                "nwtco","ova","prostate","prostateSurvival","rdata","retinopathy","rott2",
                "whas500","zinc")

  rows <- list()
  for (i in seq_along(DATASETS)) {
    ds <- DATASETS[i]
    task <- tasks[[ds]]
    y <- task$truth()
    status <- y[, 2]
    stopifnot(all(status %in% c(0, 1)))

    n <- length(status)
    n_events <- sum(status == 1)
    n_censored <- sum(status == 0)
    rate_computed <- 100 * n_censored / n

    rows[[i]] <- data.frame(
      dataset = ds, n = n, n_events = n_events, n_censored = n_censored,
      censoring_rate = rate_computed,
      existing_hardcoded_pct = unname(existing_pct[ds]),
      diff_abs = abs(rate_computed - unname(existing_pct[ds]))
    )
  }

  out <- do.call(rbind, rows)
  print(out)

  cat("\n=== Coding dogrulamasi ===\nTum status degerleri {0,1} icinde - OK\n")
  cat("\n=== Hardcoded vs ham-veriden hesaplanan fark (mutlak puan) ===\n")
  cat("Max fark:", round(max(out$diff_abs), 3), "| Ortalama fark:", round(mean(out$diff_abs), 3), "\n")
  large_diff <- out[out$diff_abs > 1, ]
  if (nrow(large_diff) > 0) {
    cat("\n1 puandan BUYUK fark olan datasetler:\n")
    print(large_diff)
  } else {
    cat("1 puandan buyuk fark olan dataset YOK - iki kaynak tutarli.\n")
  }

  dir.create("rq6/data", recursive = TRUE, showWarnings = FALSE)
  final <- out[, c("dataset", "n", "n_events", "n_censored", "censoring_rate")]
  write.csv(final, "results/rq5/dataset_censoring_rates.csv", row.names = FALSE)

  dir.create("rq6/diagnostics", recursive = TRUE, showWarnings = FALSE)
  write.csv(out, "results/rq5/rq6_censoring_rate_validation.csv", row.names = FALSE)

  cat("\nrq6/data/dataset_censoring_rates.csv kaydedildi (", nrow(final), "dataset ).\n")
  cat("Censoring rate araligi:", round(min(final$censoring_rate),2), "-", round(max(final$censoring_rate),2), "(%)\n")
  invisible(final)
}

#' RQ5 veri birlestirme: RQ2 agreement sonuclarini censoring rate ile
#' birlestirir + model x metrik Spearman rho. KAYNAK: R/rq5/rq6_agreement_merge.R
rq5_agreement_merge <- function() {
  setwd("~/Survival-XAI")
  suppressMessages(library(dplyr))

  censoring <- read.csv("results/rq5/dataset_censoring_rates.csv", stringsAsFactors = FALSE)

  wk   <- read.csv("results/rq2/rq2_weighted_kendall_long.csv", stringsAsFactors = FALSE)
  top3 <- read.csv("results/rq2/rq2_top3_overlap_long.csv", stringsAsFactors = FALSE)
  kl   <- read.csv("results/rq2/rq2_symmetric_kl_long.csv", stringsAsFactors = FALSE)

  cat("weighted_kendall_long satir:", nrow(wk), " sutunlar:", paste(names(wk), collapse=","), "\n")
  cat("top3_overlap_long satir:", nrow(top3), " sutunlar:", paste(names(top3), collapse=","), "\n")
  cat("symmetric_kl_long satir:", nrow(kl), " sutunlar:", paste(names(kl), collapse=","), "\n")

  for (nm in c("wk","top3","kl")) {
    d <- get(nm)
    un <- setdiff(unique(d$dataset), censoring$dataset)
    if (length(un) > 0) cat("UYARI:", nm, "icinde censoring'de olmayan dataset:", paste(un, collapse=","), "\n")
  }

  merge_metric <- function(metric_df, value_col, metric_name) {
    m <- metric_df %>%
      inner_join(censoring %>% select(dataset, censoring_rate), by = "dataset") %>%
      mutate(metric = metric_name, value = .data[[value_col]]) %>%
      select(dataset, model, metric, censoring_rate, value)
    m
  }

  merged <- bind_rows(
    merge_metric(wk, "weighted_tau", "weighted_tau"),
    merge_metric(top3, "overlap_at_3", "overlap_at_3"),
    merge_metric(kl, "symmetric_kl", "symmetric_kl")
  )

  dir.create("rq6/data", recursive = TRUE, showWarnings = FALSE)
  write.csv(merged, "results/rq5/rq6_censoring_agreement.csv", row.names = FALSE)
  cat("\nrq6_censoring_agreement.csv satir sayisi:", nrow(merged), "(beklenen", 3*288, ")\n")

  combos <- merged %>% distinct(model, metric)
  corr_rows <- list()
  for (i in seq_len(nrow(combos))) {
    md <- combos$model[i]; mt <- combos$metric[i]
    sub <- merged %>% filter(model == md, metric == mt, is.finite(value), is.finite(censoring_rate))
    n_ds <- nrow(sub)
    rho <- if (n_ds >= 2 && length(unique(sub$censoring_rate)) > 1 && length(unique(sub$value)) > 1) {
      tryCatch(cor(sub$censoring_rate, sub$value, method = "spearman"), error = function(e) NA_real_)
    } else NA_real_
    corr_rows[[i]] <- data.frame(model = md, metric = mt, n_datasets = n_ds, spearman_rho = rho)
  }
  corr_df <- do.call(rbind, corr_rows) %>% arrange(metric, model)
  write.csv(corr_df, "results/rq5/rq6_agreement_correlations.csv", row.names = FALSE)

  cat("\n=== rq6_agreement_correlations.csv (", nrow(corr_df), "satir, beklenen 36) ===\n")
  print(as.data.frame(corr_df))

  missing <- corr_df %>% filter(is.na(spearman_rho))
  cat("\nHesaplanamayan kombinasyon:", if(nrow(missing)==0) "YOK" else nrow(missing), "\n")
  if (nrow(missing) > 0) print(missing)

  cat("\nBITTI\n")
  invisible(list(merged = merged, correlations = corr_df))
}

#' RQ5 ozet tablolari + diagnostics. KAYNAK: R/rq5/rq6_tables_diagnostics.R
#' NOT: results/additional_analyses/censoring_tivm_relationship/ altindaki
#' dosyalara da bagimlidir (RQ1-5 disi, ek analiz kategorisi).
rq5_tables_diagnostics <- function() {
  setwd("~/Survival-XAI")
  suppressMessages(library(dplyr))

  dir.create("rq6/tables", recursive = TRUE, showWarnings = FALSE)
  dir.create("rq6/diagnostics", recursive = TRUE, showWarnings = FALSE)

  censoring <- read.csv("results/rq5/dataset_censoring_rates.csv", stringsAsFactors = FALSE)
  tivm_corr <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_tivm_correlations.csv", stringsAsFactors = FALSE)
  agree_corr <- read.csv("results/rq5/rq6_agreement_correlations.csv", stringsAsFactors = FALSE)
  tivm_merged <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_censoring_tivm.csv", stringsAsFactors = FALSE)
  agree_merged <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)

  write.csv(tivm_corr %>% select(model, method, spearman_rho, n_datasets),
            "results/additional_analyses/censoring_tivm_relationship/rq6_tivm_summary.csv", row.names = FALSE)

  write.csv(agree_corr %>% select(model, metric, spearman_rho, n_datasets),
            "results/rq5/rq6_agreement_summary.csv", row.names = FALSE)

  method_dist <- tivm_corr %>%
    group_by(method) %>%
    summarise(
      median_rho = median(spearman_rho, na.rm = TRUE),
      mean_rho   = mean(spearman_rho, na.rm = TRUE),
      Q1 = quantile(spearman_rho, 0.25, na.rm = TRUE),
      Q3 = quantile(spearman_rho, 0.75, na.rm = TRUE),
      min = min(spearman_rho, na.rm = TRUE),
      max = max(spearman_rho, na.rm = TRUE),
      .groups = "drop"
    )
  write.csv(method_dist, "results/additional_analyses/censoring_tivm_relationship/rq6_tivm_method_rho_distribution.csv", row.names = FALSE)
  cat("=== TIVM correlation - method bazinda rho dagilimi ===\n")
  print(as.data.frame(method_dist))

  diag <- list()

  TIVM24 <- unique(tivm_merged$dataset)
  missing_cens <- setdiff(TIVM24, censoring$dataset)
  diag$missing_censoring_datasets <- if (length(missing_cens)==0) "YOK" else paste(missing_cens, collapse=";")

  diag$censoring_rate_format <- sprintf("0-100 (yuzde) - min=%.2f max=%.2f", min(censoring$censoring_rate), max(censoring$censoring_rate))

  diag$event_censor_coding <- "dogrulandi: tum status degerleri {0,1} (1=event,0=censored, mlr3proba konvansiyonu)"

  dup_check <- censoring %>% group_by(dataset) %>% summarise(n_distinct_rate = n_distinct(censoring_rate))
  diag$duplicate_inconsistent_rates <- if (all(dup_check$n_distinct_rate == 1)) "YOK (her dataset tek deger)" else paste(dup_check$dataset[dup_check$n_distinct_rate>1], collapse=";")

  diag$tivm_dataset_mismatch <- if (length(setdiff(TIVM24, censoring$dataset))==0 && length(setdiff(censoring$dataset, TIVM24))==0) "YOK" else "VAR (yukariya bakiniz)"

  agree_datasets <- unique(agree_merged$dataset)
  diag$agreement_dataset_mismatch <- if (length(setdiff(agree_datasets, censoring$dataset))==0) "YOK" else paste(setdiff(agree_datasets, censoring$dataset), collapse=";")

  n_missing_tivm <- sum(is.na(tivm_corr$spearman_rho))
  n_missing_agree <- sum(is.na(agree_corr$spearman_rho))
  diag$tivm_uncomputable_combos <- n_missing_tivm
  diag$agreement_uncomputable_combos <- n_missing_agree

  penalized_zero <- tivm_merged %>% filter(model == "Penalized", TIVM == 0)
  diag$penalized_tivm_zero_artifact_rows <- nrow(penalized_zero)
  diag$penalized_tivm_zero_artifact_note <- if (nrow(penalized_zero) > 0) {
    paste0("UYARI: Penalized icin ", nrow(penalized_zero),
           " satirda TIVM=0 - bu RQ4'te tespit edilen R_bar=NA artefaktidir (dataDIVAT3, rott2), ",
           "gercek 'sifir degiskenlik' degildir. Penalized'in censoring-TIVM rho'su bu 2 sahte-sifir ",
           "noktayi icerir (n_datasets=24, digerleri 22).")
  } else {
    "yok"
  }

  diag_df <- data.frame(check = names(diag), result = unlist(diag))
  write.csv(diag_df, "results/rq5/rq6_diagnostics.csv", row.names = FALSE)

  cat("\n=== rq6_diagnostics.csv ===\n")
  print(diag_df, row.names = FALSE)

  cat("\nBITTI\n")
  invisible(diag_df)
}

#' Figure (RQ5, GUNCEL/MAKALE versiyonu): gercek ggstatsplot::ggscatterstats,
#' 3 panel, Spearman istatistikleri. KAYNAK: R/rq5/rq5_ggscatterstats_refined.R
rq5_ggscatterstats_refined <- function() {
  setwd("~/Survival-XAI")
  .libPaths(c("~/R/library", .libPaths()))
  suppressMessages({
    library(ggstatsplot)
    library(ggside)
    library(dplyr)
    library(ggplot2)
  })

  pooled <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)
  pooled <- pooled %>% filter(is.finite(value), is.finite(censoring_rate))

  fmt_p <- function(p) if (p < 0.001) "p < 0.001" else sprintf("p = %.3f", p)

  two_breaks <- function(limits) {
    hi <- floor(limits[2] / 5) * 5
    if (hi <= 0) hi <- round(limits[2] * 0.85)
    c(0, hi)
  }

  mk <- function(metric_name, ylab, title_lab) {
    d <- pooled %>% filter(metric == metric_name)

    st <- statsExpressions::corr_test(d, censoring_rate, value, type = "nonparametric")
    rho   <- st$estimate
    Sval  <- st$statistic
    pval  <- st$p.value
    ci_lo <- st$conf.low
    ci_hi <- st$conf.high
    n     <- st$n.obs

    subtitle_txt <- sprintf(
      "rho = %.2f  [%.2f, %.2f]   S = %.2e   %s   n = %d",
      rho, ci_lo, ci_hi, Sval, fmt_p(pval), n
    )

    p <- ggscatterstats(
      data = d,
      x = censoring_rate,
      y = value,
      type = "nonparametric",
      marginal = TRUE,
      bf.message = FALSE,
      results.subtitle = FALSE,
      point.args = list(size = 1.8, alpha = 0.35, stroke = 0, color = "grey30"),
      smooth.line.args = list(linewidth = 1.1, color = "#2166ac", method = "lm",
                               formula = y ~ x, alpha = 0.15),
      xsidehistogram.scale = 0.28,
      ysidehistogram.scale = 0.28,
      xlab = "Censoring Rate (%)",
      ylab = ylab,
      title = title_lab,
      subtitle = subtitle_txt,
      ggtheme = ggplot2::theme_bw(base_size = 20),
      ggplot.component = list(
        ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 4)),
        ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 5)),
        ggplot2::theme(
          plot.margin      = ggplot2::margin(t = 10, r = 34, b = 10, l = 14),
          plot.title       = ggplot2::element_text(size = 18, face = "bold"),
          plot.subtitle    = ggplot2::element_text(size = 13, color = "grey20"),
          axis.title.y     = ggplot2::element_text(margin = ggplot2::margin(r = 12)),
          axis.title.x     = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
          ggside.axis.text  = ggplot2::element_text(size = 9, color = "grey30"),
          ggside.panel.grid = ggplot2::element_blank()
        )
      )
    )

    p <- p +
      ggside::scale_xsidey_continuous(
        breaks = two_breaks
      ) +
      ggside::scale_ysidex_continuous(
        breaks = two_breaks,
        position = "top"
      )
    p
  }

  p1 <- mk("weighted_tau", "Weighted Kendall's Tau", "A: Weighted Kendall")
  p2 <- mk("overlap_at_3", "Top-3 Overlap",           "B: Top-3 Overlap")
  p3 <- mk("symmetric_kl", "Symmetric KL Divergence", "C: Symmetric KL")

  combined <- combine_plots(
    list(p1, p2, p3),
    plotgrid.args = list(nrow = 1, ncol = 3)
  ) & ggplot2::theme(plot.margin = ggplot2::margin(l = 10, r = 10))

  dir.create("rq5/figures", recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave("figures/rq5/RQ5_ggstatsplot_refined.pdf", plot = combined,
                   width = 24, height = 8.5, dpi = 300, bg = "white", limitsize = FALSE)
  ggplot2::ggsave("figures/rq5/RQ5_ggstatsplot_refined.png", plot = combined,
                   width = 24, height = 8.5, dpi = 300, bg = "white", limitsize = FALSE)

  cat("Kaydedildi: rq5/figures/RQ5_ggstatsplot_refined.{png,pdf} (24x8.5in, 300dpi)\n")
  combined
}

#' RQ5 denetim raporu: merge dogrulugu + bagimsiz cor.test tekrari.
#' KAYNAK: R/rq5/rq5_audit_report.R
rq5_audit_report <- function() {
  setwd("~/Survival-XAI")
  suppressMessages(library(dplyr))

  pooled <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)
  pooled <- pooled %>% filter(is.finite(value), is.finite(censoring_rate))

  panel_spec <- list(
    list(metric = "weighted_tau", label = "Weighted Kendall's Tau"),
    list(metric = "overlap_at_3", label = "Top-3 Overlap"),
    list(metric = "symmetric_kl", label = "Symmetric KL Divergence")
  )

  results <- lapply(panel_spec, function(spec) {
    d <- pooled %>% filter(metric == spec$metric)
    ct <- suppressWarnings(cor.test(d$censoring_rate, d$value, method = "spearman", exact = FALSE))
    data.frame(
      metric = spec$metric,
      label = spec$label,
      n = nrow(d),
      rho = unname(ct$estimate),
      S_statistic = unname(ct$statistic),
      p_value = ct$p.value,
      stringsAsFactors = FALSE
    )
  })
  results_df <- bind_rows(results)
  print(results_df)

  audit <- data.frame(
    check = c(
      "Onceki oturumda 'kritik merge hatasi' iddiasi",
      "Yontem: cikti CSV'nin deger sutunu ile taze merge'un deger sutunu != ile karsilastirildi",
      "Bulgu: 644/864 (ve metrige gore 226-286/286) satir 'farkli' isaretlendi",
      "Kok neden testi: ayni satirlar 17 basamak tam hassasiyetle yazdirildi",
      "Ornek: aids2/CTree/overlap_at_3 -> merged=0.83333333333333326 disk=0.83333333333333304",
      "Fark buyuklugu",
      "all.equal(merged$value, disk$value)",
      "1e-9 tolerans ile gercekten farkli satir sayisi",
      "SONUC"
    ),
    detail = c(
      "rq6_agreement_merge.R'nin inner_join/mutate/bind_rows mantigi bozuk zannedildi",
      "Bu yontem CSV write/read round-trip'inden kaynaklanan double hassasiyet gurultusune (~1e-16) karsi yanlis pozitif uretir",
      "Yanlis alarm - gercek veri bozulmasi degil",
      "merge_metric() ham dosyalar uzerinde izole calistirildi, deger dogru geldi",
      "Iki deger goruntude ozdes, farkli sadece son ondalik basamaklarda",
      "2.22e-16 (makine epsilon seviyesi, IEEE 754 double precision sinirinda)",
      "TRUE",
      "0 / 864",
      "rq6_agreement_merge.R DOGRU calisiyor. rq6_censoring_agreement.csv, rq6_agreement_correlations.csv, rq5_heatmap_values.csv, RQ5_heatmap.png/pdf, RQ5_ggstatsplot.png/pdf (gercek ggstatsplot versiyonu) GECERLI. Hicbir dosya degistirilmedi/yeniden uretilmedi."
    ),
    stringsAsFactors = FALSE
  )

  dir.create("rq5/data", recursive = TRUE, showWarnings = FALSE)
  write.csv(audit, "results/rq5/RQ5_audit_report.csv", row.names = FALSE)
  write.csv(results_df, "results/rq5/RQ5_audit_correlations_reconfirmed.csv", row.names = FALSE)
  cat("\nYazildi: rq5/data/RQ5_audit_report.csv, rq5/data/RQ5_audit_correlations_reconfirmed.csv\n")
  invisible(list(audit = audit, results = results_df))
}

#' Figure (RQ5, eski/basit iterasyon - 3'u bir arada): censoring-TIVM facet,
#' censoring-TIVM rho dumbbell, censoring-agreement 3 panel scatter.
#' KAYNAK: R/rq5/rq6_figures_SHARED.R (ayni dosya R/additional_analyses/
#' censoring_tivm_relationship/ altinda da mevcuttur - iki kategoriye de
#' ait oldugu icin paylasilmistir).
rq5_figures_legacy <- function() {
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
  invisible(list(p1 = p1, p2 = p2, p3 = p3))
}


# =============================================================================
# EK ANALIZ (RQ1-RQ5 DISI) - Censoring Rate Kesif Grafikleri
# =============================================================================
# Bu iki fonksiyon RQ1/RQ2'nin ANA kodu DEGILDIR - censoring rate ile
# erken/kesifsel bir iliskilendirme denemesidir (RQ5'in erken taslaklari).
# Girdi dosyalari ("results/rq1/rq1_long.csv", "results/rq2/rq2_long.csv")
# mevcut RQ1/RQ2 sonuc dosyalarindan FARKLI bir sema (tau/top3/kl sutunlari)
# bekler ve su an REPODA BULUNMAMAKTADIR - bu iki fonksiyon calismaz.

#' KESIFSEL (RQ1 degil): censoring rate vs RQ1 model-arasi uyum.
#' KAYNAK: R/additional_analyses/censoring_exploratory/rq1_censoring_plot.R
censoring_exploratory_rq1_plot <- function() {
  suppressMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(ggrepel)
  })

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

  df <- read.csv("results/rq1/rq1_long.csv")  # SEMA FARKLI, bkz README

  df$method <- factor(df$method, levels = c("SurvSHAP", "SurvPFI"))

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

  df_pairs <- df_long %>%
    select(dataset, censor_rate, metric, method, mean_value) %>%
    pivot_wider(names_from = method, values_from = mean_value) %>%
    mutate(y_mid = (SurvSHAP + SurvPFI) / 2)

  method_colors <- c("SurvSHAP" = "#2166ac", "SurvPFI" = "#d73027")

  p_rq1_trend <- ggplot(df_long, aes(x = censor_rate, y = mean_value,
                                     color = method, fill = method)) +
    geom_segment(data = df_pairs,
                 aes(x = censor_rate, xend = censor_rate,
                     y = SurvSHAP, yend = SurvPFI),
                 color = "grey65", linewidth = 0.6, linetype = "solid",
                 inherit.aes = FALSE) +
    geom_point(shape = 21, size = 3.5, stroke = 0.6, alpha = 0.55) +
    geom_text_repel(data = df_pairs,
                    aes(x = censor_rate, y = y_mid, label = dataset),
                    size = 3.2,
                    max.overlaps = 8,
                    color = "grey35",
                    family = "Courier",
                    inherit.aes = FALSE) +
    geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
                alpha = 0.15, linewidth = 0.9) +
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

  # ggsave("rq1_censoring_paired_alpha.png", plot = p_rq1_trend, width = 15, height = 6, dpi = 300, bg = "white")

  p_rq1_trend
}

#' KESIFSEL (RQ2 degil): censoring rate vs RQ2 SurvSHAP-SurvPFI uyumu.
#' KAYNAK: R/additional_analyses/censoring_exploratory/rq2_censoring_plot.R
censoring_exploratory_rq2_plot <- function() {
  suppressMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(ggrepel)
  })

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

  df <- read.csv("results/rq2/rq2_long.csv")  # SEMA FARKLI, DOSYA REPODA YOK - bkz README

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
    group_by(dataset, metric) %>%
    summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop") %>%
    inner_join(censor_tbl, by = "dataset")

  p_rq2_trend <- ggplot(df_long, aes(x = censor_rate, y = mean_value)) +
    geom_point(shape = 16, size = 3, color = "grey35", alpha = 0.7) +
    geom_text_repel(aes(label = dataset),
                    size = 3.2,
                    max.overlaps = 7,
                    color = "grey35",
                    family = "Courier") +
    geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
                alpha = 0.15, linewidth = 0.9) +
    facet_wrap(vars(metric), nrow = 1) +
    scale_x_continuous(labels = function(x) paste0(x),
                       breaks = seq(0, 100, by = 20),
                       limits = c(0, 105)) +
    labs(
      x = "Censoring Rate (%)",
      y = "Mean Agreement"
    ) +
    theme_bw(base_size = 20) +
    theme(
      panel.grid.minor = element_blank()
    )

  # ggsave("rq2_censoring_lm.png", plot = p_rq2_trend, width = 15, height = 5.5, dpi = 300, bg = "white")

  p_rq2_trend
}
