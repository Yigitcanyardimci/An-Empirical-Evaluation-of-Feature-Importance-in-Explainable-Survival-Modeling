args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Kullanim: Rscript R/00_run_dataset.R <dataset_adi> [model1,model2,...]")
dataset_name_arg <- args[1]
models_arg <- if (length(args) >= 2) strsplit(args[2], ",")[[1]] else NULL

dir.create("logs", showWarnings = FALSE)
LOG_FILE <- file.path("logs", paste0(dataset_name_arg, ".log"))

source("R/01_install_packages.R")
source("R/02_import_datasets.R")
source("R/03_modeling.R")
source("R/04_performance.R")
source("R/05_global_explain.R")
source("R/06_shap_analysis.R")

fmt <- function(x, d = 4) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("NA")
  round(x, d)
}

outputs_root <- "results"

if (!dataset_name_arg %in% names(tasks)) {
  log_msg(paste("HATA: bilinmeyen veri seti:", dataset_name_arg))
  quit(status = 1)
}
tasks <- tasks[dataset_name_arg]
if (!is.null(models_arg)) {
  model_keys <- paste0(models_arg, "_model")
  learner_specs <- learner_specs[intersect(names(learner_specs), model_keys)]
}

log_msg(paste("===== RUN (", dataset_name_arg, ") BASLADI:", length(learner_specs), "model ====="))

for (dataset_name in names(tasks)) {
  result <- tryCatch({
    task <- tasks[[dataset_name]]
    log_msg(paste("----- Veri seti basladi:", dataset_name, "-----"))

    split  <- data_split(task)
    models <- train_or_load_models(task, split, dataset_name, outputs_root)

    if (length(models) == 0) {
      log_msg(paste("UYARI: hicbir model egitilemedi, veri seti atlaniyor:", dataset_name))
    } else {
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

      pfi_tivm  <- list()
      shap_tivm <- list()

      needs_explainer <- character(0)
      for (nm in names(models)) {
        spec    <- learner_specs[[nm]]
        out_dir <- file.path(outputs_root, spec$id, dataset_name)
        vimp_path <- file.path(out_dir, "vimp_summary.csv")
        shap_path <- file.path(out_dir, "shap_summary.csv")
        vimp_done <- file.exists(vimp_path)
        shap_done <- file.exists(shap_path)

        if (vimp_done) pfi_tivm[[nm]]  <- calculate_TIVM(read.csv(vimp_path))
        if (shap_done) shap_tivm[[nm]] <- calculate_TIVM(read.csv(shap_path))

        if (!vimp_done || !shap_done) {
          needs_explainer <- c(needs_explainer, nm)
        } else {
          log_msg(paste("PFI ve SHAP zaten tamam, explainer atlaniyor:", nm))
        }
      }

      if (length(needs_explainer) > 0) {
        models_subset <- models[needs_explainer]
        global <- global_explain(task, models_subset, split, dataset_name, outputs_root)
        pfi_tivm_new <- save_all_vimp(models_subset, global$vimp_list, dataset_name, outputs_root)
        for (nm in names(pfi_tivm_new)) pfi_tivm[[nm]] <- pfi_tivm_new[[nm]]

        shap_tivm_new <- save_all_survshap(
          task, models_subset, global$explainers, split,
          dataset_name, outputs_root, n_obs = 15
        )
        for (nm in names(shap_tivm_new)) shap_tivm[[nm]] <- shap_tivm_new[[nm]]
      }

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
    }
    log_msg(paste("----- Veri seti bitti:", dataset_name, "-----"))
    TRUE
  }, error = function(e) {
    log_msg(paste("KRITIK HATA:", dataset_name_arg, "-", conditionMessage(e)))
    FALSE
  })
}

log_msg(paste("===== RUN (", dataset_name_arg, ") TAMAMLANDI ====="))
