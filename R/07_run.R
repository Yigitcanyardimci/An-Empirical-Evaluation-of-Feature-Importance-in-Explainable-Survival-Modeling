# 07_run_all.R
source("00_prepare_functions.R")
source("01_install_packages.R")
source("02_import_datasets.R")
source("03_modeling.R")
source("04_performance.R")
source("05_global_explain.R")
source("06_shap_analysis.R")

fmt <- function(x, d = 4) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("NA")
  round(x, d)
}

outputs_root <- "outputs"

log_msg(paste("===== TUM RUN BASLADI:", length(tasks), "veri seti x",
              length(learner_specs), "model ====="))

for (dataset_name in names(tasks)) {
  task <- tasks[[dataset_name]]
  log_msg(paste("----- Veri seti basladi:", dataset_name, "-----"))
  
  split  <- data_split(task)
  models <- train_or_load_models(task, split, dataset_name, outputs_root)
  
  if (length(models) == 0) {
    log_msg(paste("UYARI: hicbir model egitilemedi, veri seti atlaniyor:", dataset_name))
    next
  }
  
  ## Performans
  perf_list <- lapply(names(models), function(nm) {
    spec    <- learner_specs[[nm]]
    out_dir <- file.path(outputs_root, spec$id, dataset_name)
    perf <- tryCatch(
      measure_performance(models[[nm]], task, split, spec$key),
      error = function(e) {
        log_msg(paste("HATA: performans hesaplanamadi -", spec$id, dataset_name, "-", conditionMessage(e)))
        NULL
      }
    )
    if (!is.null(perf)) save_performance(perf, out_dir)
    perf
  })
  names(perf_list) <- names(models)
  
  ## Global aciklama (PFI) - explainer cache'li
  global   <- global_explain(task, models, split, dataset_name, outputs_root)
  pfi_tivm <- save_all_vimp(models, global$vimp_list, dataset_name, outputs_root)
  
  ## SHAP
  shap_tivm <- save_all_survshap(
    task, models, global$explainers, split,
    dataset_name, outputs_root, n_obs = 15
  )
  
  ## Ozet log
  for (nm in names(models)) {
    model_id <- learner_specs[[nm]]$id
    cindex   <- if (!is.null(perf_list[[nm]])) perf_list[[nm]]$surv.cindex else NA
    
    log_msg(paste0(
      "===== BITTI: ", dataset_name, " + ", model_id,
      " - cindex: ", fmt(cindex, 3),
      " - PFI TIVM: ", fmt(pfi_tivm[[nm]]),
      " - SHAP TIVM: ", fmt(shap_tivm[[nm]]),
      " ====="
    ))
  }
  
  log_msg(paste("----- Veri seti bitti:", dataset_name, "-----"))
}

build_master_performance(outputs_root)
log_msg("===== TUM RUN TAMAMLANDI =====")
