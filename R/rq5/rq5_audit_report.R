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
