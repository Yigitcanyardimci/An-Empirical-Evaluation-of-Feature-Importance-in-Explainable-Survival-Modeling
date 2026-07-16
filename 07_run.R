# Tum adimlari sirayla calistirir.

source("R/01_install_packages.R")
source("R/02_import_datasets.R")
source("R/03_modeling.R")
source("R/04_performance.R")
source("R/05_global_explain.R")
source("R/06_shap_analysis.R")

log_msg("===== RUN BASLADI: grace + cox =====")

out_dir <- file.path("outputs", "cox", "grace")

grace_split  <- data_split(grace_task)

grace_models <- load_model_if_exists(out_dir)
if (is.null(grace_models)) {
  grace_models <- train_models(grace_task, grace_split)
  save_model(grace_models$cox_model, out_dir)
} else {
  grace_models <- list(cox_model = grace_models)
}

grace_perf_cox <- measure_performance(grace_models$cox_model, grace_task, grace_split, "surv.coxph")
save_performance(grace_perf_cox, out_dir)

grace_perf_cox$surv.cindex
grace_perf_cox$surv.dcalib
grace_perf_cox$surv.brier
grace_perf_cox$surv.logloss
grace_perf_cox$surv.mae
grace_perf_cox$surv.mse

grace_global   <- global_explain(grace_task, grace_models, grace_split)
grace_cox_vimp <- grace_global$vimp_list$cox_model
save_vimp(grace_cox_vimp, out_dir)

grace_cox_p_vimp <- plot(grace_cox_vimp) +
  theme(
    legend.title    = element_blank(),
    plot.subtitle   = element_blank(),
    plot.tag        = element_blank(),
    plot.title      = element_blank(),
    legend.position = "bottom"
  )
grace_cox_p_vimp
save_plot(grace_cox_p_vimp, out_dir, "pfi_plot")

grace_cox_summary <- calculate_vimp_summary(grace_cox_vimp)
save_vimp_summary(grace_cox_summary, out_dir)
grace_cox_summary

grace_cox_TIVM <- calculate_TIVM(grace_cox_summary)
grace_cox_TIVM

grace_test_df <- as.data.frame(grace_task$data(rows = grace_split$test))
X_test        <- grace_test_df |> select(-days, -death)
cox_explainer <- grace_global$explainers$cox_model

grace_shap_long  <- compute_survshap(cox_explainer, X_test, out_dir, n_obs = 15)
grace_shap_curve <- calculate_survshap_curve(grace_shap_long)

grace_shap_p <- plot_survshap(grace_shap_curve)
grace_shap_p
save_plot(grace_shap_p, out_dir, "survshap_plot")

grace_cox_shap_summary <- calculate_vimp_summary_from_long(grace_shap_curve)
grace_cox_shap_summary

grace_cox_shap_TIVM <- calculate_TIVM(grace_cox_shap_summary)
grace_cox_shap_TIVM

log_msg(paste("===== RUN BITTI: grace + cox - cindex:", round(grace_perf_cox$surv.cindex, 3),
              "PFI TIVM:", round(grace_cox_TIVM, 4),
              "SHAP TIVM:", round(grace_cox_shap_TIVM, 4), "====="))