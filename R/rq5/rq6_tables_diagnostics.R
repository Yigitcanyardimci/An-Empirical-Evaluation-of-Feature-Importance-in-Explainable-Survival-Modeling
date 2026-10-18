# rq6_tables_diagnostics.R
#
# RQ6 ozet tablolari (tables/) ve kapsamli diagnostics (diagnostics/).
# Hicbir yeniden hesaplama yok - sadece rq6/data/ altindaki mevcut CSV'ler
# okunup ozetlenir.

setwd("~/Survival-XAI")
suppressMessages(library(dplyr))

dir.create("rq6/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("rq6/diagnostics", recursive = TRUE, showWarnings = FALSE)

censoring <- read.csv("results/rq5/dataset_censoring_rates.csv", stringsAsFactors = FALSE)
tivm_corr <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_tivm_correlations.csv", stringsAsFactors = FALSE)
agree_corr <- read.csv("results/rq5/rq6_agreement_correlations.csv", stringsAsFactors = FALSE)
tivm_merged <- read.csv("results/additional_analyses/censoring_tivm_relationship/rq6_censoring_tivm.csv", stringsAsFactors = FALSE)
agree_merged <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)

# ── rq6_tivm_summary.csv (tables/) ───────────────────────────────────────
write.csv(tivm_corr %>% select(model, method, spearman_rho, n_datasets),
          "results/additional_analyses/censoring_tivm_relationship/rq6_tivm_summary.csv", row.names = FALSE)

# ── rq6_agreement_summary.csv (tables/) ──────────────────────────────────
write.csv(agree_corr %>% select(model, metric, spearman_rho, n_datasets),
          "results/rq5/rq6_agreement_summary.csv", row.names = FALSE)

# ── method-level rho dagilim ozeti (yalnizca betimsel) ───────────────────
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

# =============================================================================
# DIAGNOSTICS
# =============================================================================
diag <- list()

# 1) censoring rate eksik dataset
TIVM24 <- unique(tivm_merged$dataset)
missing_cens <- setdiff(TIVM24, censoring$dataset)
diag$missing_censoring_datasets <- if (length(missing_cens)==0) "YOK" else paste(missing_cens, collapse=";")

# 2) format kontrolu (0-1 mi 0-100 mu)
diag$censoring_rate_format <- sprintf("0-100 (yuzde) - min=%.2f max=%.2f", min(censoring$censoring_rate), max(censoring$censoring_rate))

# 3) event/censor coding - script rq6_censoring_rates.R icinde stopifnot(all(status %in% c(0,1))) ile zaten dogrulandi
diag$event_censor_coding <- "dogrulandi: tum status degerleri {0,1} (1=event,0=censored, mlr3proba konvansiyonu)"

# 4) ayni dataset icin birden fazla farkli censoring_rate var mi
dup_check <- censoring %>% group_by(dataset) %>% summarise(n_distinct_rate = n_distinct(censoring_rate))
diag$duplicate_inconsistent_rates <- if (all(dup_check$n_distinct_rate == 1)) "YOK (her dataset tek deger)" else paste(dup_check$dataset[dup_check$n_distinct_rate>1], collapse=";")

# 5) TIVM eslesmeyen dataset
diag$tivm_dataset_mismatch <- if (length(setdiff(TIVM24, censoring$dataset))==0 && length(setdiff(censoring$dataset, TIVM24))==0) "YOK" else "VAR (yukariya bakiniz)"

# 6) agreement metric eslesmeyen dataset/model
agree_datasets <- unique(agree_merged$dataset)
diag$agreement_dataset_mismatch <- if (length(setdiff(agree_datasets, censoring$dataset))==0) "YOK" else paste(setdiff(agree_datasets, censoring$dataset), collapse=";")

# 7) Spearman hesaplanamayan kombinasyonlar
n_missing_tivm <- sum(is.na(tivm_corr$spearman_rho))
n_missing_agree <- sum(is.na(agree_corr$spearman_rho))
diag$tivm_uncomputable_combos <- n_missing_tivm
diag$agreement_uncomputable_combos <- n_missing_agree

# ── Penalized/TIVM=0 artefakt uyarisi (RQ4'te tespit edilen bilinen sorun) ──
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
