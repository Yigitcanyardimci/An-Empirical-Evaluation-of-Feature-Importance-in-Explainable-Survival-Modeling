# 04_performance.R
measure_performance <- function(model, task, split, model_id, params = NULL) {
  log_msg(paste("Performans hesaplama basladi:", model_id))

  preds <- model$predict(task, row_ids = split$test)

  get_score <- function(key, ...) {
    tryCatch(
      as.numeric(preds$score(msr(key), task = task, ...))[1],
      error = function(e) {
        log_msg(paste("UYARI:", key, "hesaplanamadi -", model_id, "-", conditionMessage(e)))
        NA_real_
      }
    )
  }

  response_metrics <- tryCatch({
    response_base_learner <- lrn(model_id, id = paste0(model_id, "_response"))
    if (!is.null(params) && length(params) > 0) {
      response_base_learner$param_set$set_values(.values = params)
    }
    response_learner <- mlr3pipelines::ppl(
      "responsecompositor",
      learner       = response_base_learner,
      method        = "median",
      overwrite     = TRUE,
      graph_learner = TRUE
    )
    response_learner$train(task, row_ids = split$train)
    response_preds <- response_learner$predict(task, row_ids = split$test)
    
    list(
      mae = as.numeric(response_preds$score(msr("surv.mae"), task = task, train_set = split$train))[1],
      mse = as.numeric(response_preds$score(msr("surv.mse"), task = task, train_set = split$train))[1]
    )
  }, error = function(e) {
    log_msg(paste("UYARI: mae/mse hesaplanamadi -", model_id, "-", conditionMessage(e)))
    list(mae = NA_real_, mse = NA_real_)
  })
  
  sonuc <- list(
    model        = model_id,
    surv.cindex  = get_score("surv.cindex"),
    surv.dcalib  = get_score("surv.dcalib"),
    surv.brier   = get_score("surv.brier", train_set = split$train),
    surv.graf    = get_score("surv.graf", train_set = split$train),
    surv.logloss = get_score("surv.logloss"),
    surv.mae     = response_metrics$mae,
    surv.mse     = response_metrics$mse
  )
  
  log_msg(paste("Performans hesaplama bitti:", model_id,
                "- cindex:", round(sonuc$surv.cindex, 3),
                "- IBS (graf):", round(sonuc$surv.graf, 3)))
  sonuc
}

save_performance <- function(perf_list, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "performance.csv")
  as.data.frame(perf_list) |> write.csv(path, row.names = FALSE)
  log_msg(paste("Performans kaydedildi:", path))
}

build_master_performance <- function(outputs_root = "outputs",
                                     out_path = file.path(outputs_root, "all_performance.csv")) {
  files <- list.files(outputs_root, pattern = "^performance\\.csv$", recursive = TRUE, full.names = TRUE)
  if (length(files) == 0) {
    log_msg("Master performans: performance.csv bulunamadi")
    return(invisible(NULL))
  }
  
  rows <- lapply(files, function(f) {
    df <- read.csv(f, stringsAsFactors = FALSE)
    df$dataset  <- basename(dirname(f))
    df$model_id <- basename(dirname(dirname(f)))
    df
  })
  
  master <- dplyr::bind_rows(rows) |>
    select(model_id, dataset, everything())
  
  write.csv(master, out_path, row.names = FALSE)
  log_msg(paste("Master performans tablosu kaydedildi:", out_path, "-", nrow(master), "satir"))
  master
}
