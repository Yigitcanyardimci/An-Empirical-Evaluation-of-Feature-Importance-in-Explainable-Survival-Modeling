# ===== R/04_performance.R =====
# Performans metriklerini hesaplar.

measure_performance <- function(model, task, split, model_id) {
  log_msg(paste("Performans hesaplama basladi:", model_id))
  
  preds <- model$predict(task, row_ids = split$test)
  
  get_score <- function(key, ...) {
    tryCatch(
      as.numeric(preds$score(msr(key), task = task, ...))[1],
      error = function(e) {
        log_msg(paste("UYARI:", key, "hesaplanamadi -", conditionMessage(e)))
        NA_real_
      }
    )
  }
  
  response_metrics <- tryCatch({
    response_learner <- mlr3pipelines::ppl(
      "responsecompositor",
      learner       = lrn(model_id, id = paste0(model_id, "_response")),
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
    log_msg(paste("UYARI: mae/mse hesaplanamadi -", conditionMessage(e)))
    list(mae = NA_real_, mse = NA_real_)
  })
  
  sonuc <- list(
    surv.cindex  = get_score("surv.cindex"),
    surv.dcalib  = get_score("surv.dcalib"),
    surv.brier   = get_score("surv.brier", train_set = split$train),
    surv.logloss = get_score("surv.logloss"),
    surv.mae     = response_metrics$mae,
    surv.mse     = response_metrics$mse
  )
  
  log_msg(paste("Performans hesaplama bitti:", model_id,
                "- cindex:", round(sonuc$surv.cindex, 3)))
  sonuc
}

# Sonuclari diske kaydeder.
save_performance <- function(perf_list, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "performance.csv")
  as.data.frame(perf_list) |> write.csv(path, row.names = FALSE)
  log_msg(paste("Performans kaydedildi:", path))
}