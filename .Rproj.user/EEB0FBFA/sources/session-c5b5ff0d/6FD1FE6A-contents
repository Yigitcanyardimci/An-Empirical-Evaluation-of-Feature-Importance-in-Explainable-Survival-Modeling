compute_survshap <- function(explainer, X_test, n_obs = 15) {
  n_obs      <- min(n_obs, nrow(X_test))
  obs_subset <- X_test[seq_len(n_obs), , drop = FALSE]
  
  shap_list <- lapply(seq_len(n_obs), function(i) {
    res   <- survex::predict_parts(explainer, new_observation = obs_subset[i, , drop = FALSE], type = "survshap")
    mat   <- as.data.frame(res$result)
    times <- as.numeric(gsub("^t=", "", rownames(mat)))
    
    mat %>%
      mutate(`_times_` = times, obs_id = i) %>%
      pivot_longer(-c(`_times_`, obs_id), names_to = "variable", values_to = "phi")
  })
  
  bind_rows(shap_list)
}

calculate_survshap_curve <- function(shap_long) {
  shap_long %>%
    group_by(variable, `_times_`) %>%
    summarise(fj_t = mean(abs(phi), na.rm = TRUE), .groups = "drop")
}

plot_survshap <- function(shap_curve) {
  ggplot(shap_curve, aes(x = `_times_`, y = fj_t, color = variable)) +
    geom_line(linewidth = 1) +
    labs(
      x     = "time",
      y     = "SurvSHAP(t)",
      color = NULL,
      title = ""
    ) +
    theme_minimal(base_size = 20) +
    theme(legend.position = "bottom")
}