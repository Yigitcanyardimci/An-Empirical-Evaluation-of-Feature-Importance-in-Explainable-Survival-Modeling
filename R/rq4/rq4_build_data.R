# rq4_build_data.R
#
# Bu script HICBIR modeli yeniden egitmez, HICBIR SurvSHAP/SurvPFI analizini
# yeniden calistirmaz. Sadece projenin daha once ürettigi, zaten diskte
# duran vimp_summary.csv (SurvPFI) ve shap_summary_n100.csv (SurvSHAP, N=100)
# dosyalarini okur ve bunlarin icindeki R_bar/TIV sutunlarindan TIVM'yi
# (=sum(R_bar*TIV)) turetir - tipki projenin kendi R/00_run_dataset.R
# script'inin resume sirasinda yaptigi gibi (calculate_TIVM(read.csv(...))).

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

    # --- SurvPFI (vimp_summary.csv) ---
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

    # --- SurvSHAP (shap_summary_n100.csv) ---
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
