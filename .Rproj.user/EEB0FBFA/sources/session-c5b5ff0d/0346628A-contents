source("01_install_packages.R")
source("02_import_datasets.R")
source("03_task.R")
source("04_data_split.R")
source("05_modeling.R")
source("06_performance.R")
source("07_global_explain.R")
source("08_vimp_analysis.R")
source("09_shap_analysis.R")


grace_split  <- data_split(grace_task)
grace_models <- train_models(grace_task, grace_split)


grace_perf_cox <- measure_performance(grace_models$cox_model, grace_task, grace_split)
grace_perf_cox$surv.cindex
grace_perf_cox$surv.brier
grace_perf_cox$surv.logloss
grace_perf_cox$surv.mae
grace_perf_cox$surv.mse


grace_global   <- global_explain(grace_task, grace_models, grace_split)
grace_cox_vimp <- grace_global$vimp_list$cox_model

grace_cox_p_vimp <- plot(grace_cox_vimp) +
  theme(
    legend.title    = element_blank(),
    plot.subtitle   = element_blank(),
    plot.tag        = element_blank(),
    plot.title      = element_blank(),
    legend.position = "bottom"
  )
grace_cox_p_vimp

grace_cox_summary <- calculate_vimp_summary(grace_cox_vimp)
grace_cox_summary

grace_cox_TIVM <- calculate_TIVM(grace_cox_summary)
grace_cox_TIVM



grace_test_df <- as.data.frame(grace_task$data(rows = grace_split$test))
X_test        <- grace_test_df %>% select(-days, -death)

cox_explainer <- grace_global$explainers$cox_model

grace_shap_long  <- compute_survshap(cox_explainer, X_test, n_obs = 15)
grace_shap_curve <- calculate_survshap_curve(grace_shap_long)

grace_shap_p <- plot_survshap(grace_shap_curve)
grace_shap_p

grace_cox_shap_summary <- calculate_vimp_summary_from_long(grace_shap_curve)
grace_cox_shap_summary

grace_cox_shap_TIVM <- calculate_TIVM(grace_cox_shap_summary)
grace_cox_shap_TIVM





