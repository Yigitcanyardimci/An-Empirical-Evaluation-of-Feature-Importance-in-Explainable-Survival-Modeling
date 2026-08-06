# 06_shap_analysis.R
compute_survshap <- function(explainer, X_test, out_dir, n_obs = 15) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  # n_obs=15 icin dosya adlari eskisiyle birebir ayni (bu dosyalar hicbir
  # zaman silinmez/uzerine yazilmaz). n_obs != 15 icin "_n<n_obs>" ekli
  # AYRI dosyalar kullanilir (orn. shap_long_n50.csv), n=15 sonuclarinin
  # yanina eklenir.
  suffix       <- if (n_obs == 15) "" else paste0("_n", n_obs)
  path         <- file.path(out_dir, paste0("shap_long", suffix, ".csv"))
  partial_path <- file.path(out_dir, paste0("shap_long", suffix, "_partial.csv"))
  seed_path    <- file.path(out_dir, "shap_long.csv")

  if (file.exists(path)) {
    log_msg(paste("Kaydedilmis SHAP bulundu, okunuyor:", path))
    return(read.csv(path, check.names = FALSE))
  }

  n_obs      <- min(n_obs, nrow(X_test))
  obs_subset <- X_test[seq_len(n_obs), , drop = FALSE]

  # X_test'in ilk n_obs satiri deterministik oldugu icin, n=15 icin daha once
  # hesaplanmis sonuc (seed_path) birebir gecerli bir alt kumedir - SILINMEDEN
  # sadece okunup kismi dosyaya kopyalanir, boylece 1-15 arasi gozlemler
  # tekrar hesaplanmaz.
  if (n_obs > 15 && !file.exists(partial_path) && file.exists(seed_path)) {
    seed_df <- tryCatch(read.csv(seed_path, check.names = FALSE), error = function(e) NULL)
    if (!is.null(seed_df) && "obs_id" %in% names(seed_df)) {
      write.table(seed_df, partial_path, sep = ",", row.names = FALSE, col.names = TRUE, append = FALSE)
      log_msg(paste("Mevcut n=15 SHAP sonucu tohum olarak kullanildi (silinmedi):",
                    length(unique(seed_df$obs_id)), "gozlem"))
    }
  }

  done_obs <- integer(0)
  if (file.exists(partial_path)) {
    partial_df <- tryCatch(read.csv(partial_path, check.names = FALSE), error = function(e) NULL)
    if (!is.null(partial_df) && "obs_id" %in% names(partial_df)) {
      done_obs <- unique(partial_df$obs_id)
    }
    log_msg(paste("Kismi SHAP bulundu,", length(done_obs), "gozlem zaten hesaplanmis, devam ediliyor"))
  }

  log_msg(paste("SHAP hesaplama basladi, n_obs =", n_obs))

  remaining <- setdiff(seq_len(n_obs), done_obs)

  for (i in remaining) {
    if (i %% 5 == 0) log_msg(paste("SHAP - gozlem", i, "/", n_obs))
    res   <- survex::predict_parts(explainer, new_observation = obs_subset[i, , drop = FALSE], type = "survshap")
    mat   <- as.data.frame(res$result)
    times <- as.numeric(gsub("^t=", "", rownames(mat)))

    obs_long <- mat |>
      mutate(`_times_` = times, obs_id = i) |>
      pivot_longer(-c(`_times_`, obs_id), names_to = "variable", values_to = "phi")

    write.table(obs_long, partial_path, sep = ",", row.names = FALSE,
                col.names = !file.exists(partial_path), append = file.exists(partial_path))
  }

  shap_long <- read.csv(partial_path, check.names = FALSE)
  write.csv(shap_long, path, row.names = FALSE)
  file.remove(partial_path)
  log_msg(paste("SHAP hesaplama bitti, kaydedildi:", path))
  shap_long
}

calculate_survshap_curve <- function(shap_long) {
  shap_long |>
    group_by(variable, `_times_`) |>
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

save_plot <- function(plot_obj, out_dir, name, width = 10, height = 6) {
  plots_dir <- file.path(out_dir, "plots")
  dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(plots_dir, paste0(name, ".png"))
  ggsave(path, plot_obj, width = width, height = height)
  log_msg(paste("Grafik kaydedildi:", path))
}

save_all_survshap <- function(task, models, explainers, split, dataset_name,
                              outputs_root = "outputs", n_obs = 15) {
  target_names <- task$target_names
  test_df <- as.data.frame(task$data(rows = split$test))
  X_test  <- test_df |> select(-all_of(target_names))

  tivm_list <- list()

  for (nm in names(models)) {
    explainer <- explainers[[nm]]
    if (is.null(explainer)) {
      log_msg(paste("SHAP atlandi (explainer yok):", nm))
      next
    }

    model_dir <- sub("_model$", "", nm)
    out_dir   <- file.path(outputs_root, model_dir, dataset_name)

    shap_long <- tryCatch(
      compute_survshap(explainer, X_test, out_dir, n_obs = n_obs),
      error = function(e) {
        log_msg(paste("HATA: SHAP hesaplanamadi -", nm, "-", conditionMessage(e)))
        NULL
      }
    )
    if (is.null(shap_long)) next

    shap_curve <- calculate_survshap_curve(shap_long)
    shap_plot  <- plot_survshap(shap_curve)
    save_plot(shap_plot, out_dir, "survshap_plot")

    shap_summary <- calculate_vimp_summary_from_long(shap_curve)
    shap_summary_path <- file.path(out_dir, "shap_summary.csv")
    write.csv(shap_summary, shap_summary_path, row.names = FALSE)
    log_msg(paste("SHAP ozeti kaydedildi:", shap_summary_path))

    TIVM <- calculate_TIVM(shap_summary)
    tivm_list[[nm]] <- TIVM
    log_msg(paste(nm, "- SHAP TIVM:", round(TIVM, 4)))
  }

  tivm_list
}
