train_models <- function(task, split) {
  set.seed(123)
  cox_model <- lrn("surv.coxph", id = "cox")
  cox_model$train(task, row_ids = split$train)
  list(cox_model = cox_model)
}