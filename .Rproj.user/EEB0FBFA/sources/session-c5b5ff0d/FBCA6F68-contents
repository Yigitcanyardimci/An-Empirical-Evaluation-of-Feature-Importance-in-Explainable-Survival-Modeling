measure_performance <- function(model, task, split) {
  preds <- model$predict(task, row_ids = split$test)
  
  get_score <- function(key, ...) {
    tryCatch(
      as.numeric(preds$score(msr(key), task = task, ...))[1],
      error = function(e) NA_real_
    )
  }
  
  response_learner <- mlr3pipelines::ppl(
    "responsecompositor",
    learner       = lrn("surv.coxph", id = "cox_response"),
    method        = "median",
    overwrite     = TRUE,
    graph_learner = TRUE
  )
  response_learner$train(task, row_ids = split$train)
  response_preds <- response_learner$predict(task, row_ids = split$test)
  
  get_response_score <- function(key) {
    tryCatch(
      as.numeric(response_preds$score(msr(key), task = task, train_set = split$train))[1],
      error = function(e) NA_real_
    )
  }
  
  list(
    surv.cindex  = get_score("surv.cindex"),
    surv.brier   = get_score("surv.brier", train_set = split$train),
    surv.logloss = get_score("surv.logloss"),
    surv.mae     = get_response_score("surv.mae"),
    surv.mse     = get_response_score("surv.mse")
  )
}