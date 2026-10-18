# rq6_agreement_merge.R
#
# RQ2'nin mevcut, DEGISTIRILMEMIS agreement sonuclarini (weighted_tau,
# overlap_at_3, symmetric_kl - projenin KENDI sutun isimleri, tahmin
# edilerek yeniden adlandirilmadi) censoring rate ile birlestirir. RQ2
# yeniden calistirilmadi.
#
# PSEUDOREPLICATION ONLEME: her model icin 24 dataset uzerinden AYRI
# Spearman rho (metrik basina).

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

# ── ANA ANALIZ: her (model, metric) icin 24 dataset uzerinden AYRI Spearman ──
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
