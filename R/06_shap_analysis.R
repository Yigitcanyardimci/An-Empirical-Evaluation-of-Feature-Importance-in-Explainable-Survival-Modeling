# SHAP degerlerini hesaplar ve egriye cevirir.

# SHAP hesaplar, dosya varsa tekrar hesaplamaz.
compute_survshap <- function(explainer, X_test, out_dir, n_obs = 15) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "shap_long.csv")
  
  if (file.exists(path)) {
    log_msg(paste("Kaydedilmis SHAP bulundu, okunuyor:", path))
    return(read.csv(path, check.names = FALSE))
  }
  
  log_msg(paste("SHAP hesaplama basladi, n_obs =", n_obs))
  
  n_obs      <- min(n_obs, nrow(X_test))
  obs_subset <- X_test[seq_len(n_obs), , drop = FALSE]
  
  shap_list <- lapply(seq_len(n_obs), function(i) {
    if (i %% 5 == 0) log_msg(paste("SHAP - gozlem", i, "/", n_obs))
    res   <- survex::predict_parts(explainer, new_observation = obs_subset[i, , drop = FALSE], type = "survshap")
    mat   <- as.data.frame(res$result)
    times <- as.numeric(gsub("^t=", "", rownames(mat)))
    
    mat |>
      mutate(`_times_` = times, obs_id = i) |>
      pivot_longer(-c(`_times_`, obs_id), names_to = "variable", values_to = "phi")
  })
  
  shap_long <- bind_rows(shap_list)
  write.csv(shap_long, path, row.names = FALSE)
  log_msg(paste("SHAP hesaplama bitti, kaydedildi:", path))
  shap_long
}

# SHAP degerlerinden global egriyi olusturur.
calculate_survshap_curve <- function(shap_long) {
  shap_long |>
    group_by(variable, `_times_`) |>
    summarise(fj_t = mean(abs(phi), na.rm = TRUE), .groups = "drop")
}

# SHAP egrisini cizer.
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

# Grafigi diske kaydeder.
save_plot <- function(plot_obj, out_dir, name, width = 10, height = 6) {
  plots_dir <- file.path(out_dir, "plots")
  dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(plots_dir, paste0(name, ".png"))
  ggsave(path, plot_obj, width = width, height = height)
  log_msg(paste("Grafik kaydedildi:", path))
}