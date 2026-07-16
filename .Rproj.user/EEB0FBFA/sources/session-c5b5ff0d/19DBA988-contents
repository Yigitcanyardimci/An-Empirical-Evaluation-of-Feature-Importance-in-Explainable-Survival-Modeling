global_explain <- function(task, models, split) {
  target_names <- task$target_names
  
  test_df <- as.data.frame(task$data(rows = split$test))
  X <- test_df %>% select(-all_of(target_names))
  y <- task$truth(rows = split$test)

  time_grid <- sort(unique(y[, 1]))
  
  explainers <- lapply(names(models), function(nm) {
    tryCatch(
      survex::explain(models[[nm]], data = X, y = y, times = time_grid, label = nm),
      error = function(e) NULL
    )
  })
  names(explainers) <- names(models)
  
  vimp_list <- lapply(names(explainers), function(nm) {
    if (is.null(explainers[[nm]])) return(NULL)
    tryCatch(survex::model_parts(explainers[[nm]]), error = function(e) NULL)
  })
  names(vimp_list) <- names(models)
  
  list(explainers = explainers, vimp_list = vimp_list)
}