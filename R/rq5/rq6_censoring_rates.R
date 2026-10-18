# rq6_censoring_rates.R
#
# 24 dataset icin censoring rate hesabi. Iki kaynak karsilastirilir:
# (1) Projenin KENDI masaustu plotting scriptlerinde (rq1+_plot.R,
#     rq2+_plot.R) zaten hardcoded olan "survival_datasets" tablosu
#     (Censoring_Rate_Percent) - bu MEVCUT/onceden hesaplanmis deger.
# (2) Ham task verisinden (task$truth()[,2], mlr3proba konvansiyonu:
#     1=event, 0=censored) dogrudan hesaplanan n/n_events/n_censored -
#     bu (1)'i DOGRULAMAK icin, tanimi degistirmeden, ayni
#     "censored/total" formulunu ham veriye uygulayarak yapilir.
#
# Censoring rate, pipeline'daki hiz amacli 1/3 alt-orneklemesinden (nwtco,
# dataDIVAT3, Framingham icin, bkz R/00_run_dataset.R) ETKILENMEMESI icin
# TAM (subsample edilmemis) ham veri uzerinden hesaplanir - bu, datasetin
# kendi tanimlayici ozelligidir, pipeline hizi icin yapilan bir kisaltmaya
# bagli olmamalidir.

setwd("~/Survival-XAI")
suppressMessages({
  source("R/01_install_packages.R")
  source("R/02_import_datasets.R")
  source("R/03_modeling.R")
})

# (1) MEVCUT (hardcoded, masaustu rq1+_plot.R / rq2+_plot.R'den BIREBIR alindi)
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
  task <- tasks[[ds]]  # TAM (subsample edilmemis) ham task
  y <- task$truth()
  status <- y[, 2]
  stopifnot(all(status %in% c(0, 1)))  # event/censor coding dogrulamasi

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
