# 05_global_explain.R

save_explainer <- function(explainer, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "explainer.rds")
  saveRDS(explainer, path)
  log_msg(paste("Explainer kaydedildi:", path))
}

load_explainer_if_exists <- function(out_dir) {
  path <- file.path(out_dir, "explainer.rds")
  if (file.exists(path)) {
    log_msg(paste("Kaydedilmis explainer bulundu, okunuyor:", path))
    return(readRDS(path))
  }
  NULL
}


global_explain <- function(task, models, split, dataset_name,
                           outputs_root = "outputs", seed = 123) {
  log_msg("Global aciklama (PFI) basladi")
  set.seed(seed)
  
  target_names <- task$target_names
  
  test_df <- as.data.frame(task$data(rows = split$test))
  X <- test_df |> select(-all_of(target_names))
  y <- task$truth(rows = split$test)
  time_grid <- sort(unique(y[, 1]))
  
  explainers <- lapply(names(models), function(nm) {
    model_dir <- sub("_model$", "", nm)
    out_dir   <- file.path(outputs_root, model_dir, dataset_name)
    
    cached <- load_explainer_if_exists(out_dir)
    if (!is.null(cached)) return(cached)
    
    log_msg(paste("Explainer kuruluyor:", nm))
    expl <- tryCatch(
      survex::explain(models[[nm]], data = X, y = y, times = time_grid, label = nm),
      error = function(e) {
        log_msg(paste("HATA: explainer kurulamadi -", nm, "-", conditionMessage(e)))
        NULL
      }
    )
    if (!is.null(expl)) save_explainer(expl, out_dir)
    expl
  })
  names(explainers) <- names(models)
  
  vimp_list <- lapply(names(explainers), function(nm) {
    if (is.null(explainers[[nm]])) {
      log_msg(paste("PFI atlandi (explainer yok):", nm))
      return(NULL)
    }
    log_msg(paste("PFI hesaplaniyor:", nm))
    tryCatch(
      survex::model_parts(explainers[[nm]]),
      error = function(e) {
        log_msg(paste("HATA: PFI hesaplanamadi -", nm, "-", conditionMessage(e)))
        NULL
      }
    )
  })
  names(vimp_list) <- names(models)
  
  log_msg("Global aciklama (PFI) bitti")
  list(explainers = explainers, vimp_list = vimp_list)
}

save_vimp <- function(vimp_obj, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "vimp.rds")
  saveRDS(vimp_obj, path)
  log_msg(paste("PFI kaydedildi:", path))
}

time_col     <- "_times_"
exclude_cols <- c(time_col, "_full_model_", "_baseline_", "_permutation_", "label", "event")

trapz <- function(x, y) {
  o <- order(x); x <- x[o]; y <- y[o]
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2, na.rm = TRUE)
}

vimp_to_long <- function(vimp_obj) {
  res       <- as.data.frame(vimp_obj$result)
  vimp_vars <- setdiff(names(res), exclude_cols)
  
  long_raw <- res |>
    select(all_of(c(time_col, vimp_vars))) |>
    pivot_longer(-all_of(time_col), names_to = "variable", values_to = "fj_t")
  
  long_raw |>
    group_by(variable, .data[[time_col]]) |>
    summarise(fj_t = mean(fj_t, na.rm = TRUE), .groups = "drop") |>
    arrange(variable, .data[[time_col]])
}

calculate_vimp_summary_from_long <- function(long_df) {
  long_df |>
    group_by(variable) |>
    summarise(
      A_hat = trapz(.data[[time_col]], pmax(fj_t, 0)),
      A_bar = trapz(.data[[time_col]], pmax(fj_t, 0)) / (max(.data[[time_col]]) - min(.data[[time_col]])),
      TIV = {
        y <- fj_t[order(.data[[time_col]])]
        d <- diff(y)
        m <- length(y)
        if (m < 2) NA_real_ else sqrt(sum(d^2) / (m - 1))
      },
      .groups = "drop"
    ) |>
    mutate(R_bar = A_bar / sum(A_bar, na.rm = TRUE)) |>
    arrange(desc(R_bar))
}

calculate_vimp_summary <- function(vimp_obj) {
  calculate_vimp_summary_from_long(vimp_to_long(vimp_obj))
}

calculate_TIVM <- function(summary_df) {
  sum(summary_df$R_bar * summary_df$TIV, na.rm = TRUE)
}

save_vimp_summary <- function(summary_df, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "vimp_summary.csv")
  write.csv(summary_df, path, row.names = FALSE)
  log_msg(paste("PFI ozeti kaydedildi:", path))
}

save_all_vimp <- function(models, vimp_list, dataset_name, outputs_root = "outputs") {
  tivm_list <- list()
  
  for (nm in names(models)) {
    vimp_obj <- vimp_list[[nm]]
    if (is.null(vimp_obj)) {
      log_msg(paste("PFI kaydi atlandi (sonuc yok):", nm))
      next
    }
    
    model_dir <- sub("_model$", "", nm)
    out_dir   <- file.path(outputs_root, model_dir, dataset_name)
    
    save_vimp(vimp_obj, out_dir)
    
    pfi_plot <- tryCatch(
      plot(vimp_obj) +
        theme(
          legend.title    = element_blank(),
          plot.subtitle   = element_blank(),
          plot.tag        = element_blank(),
          plot.title      = element_blank(),
          legend.position = "bottom"
        ),
      error = function(e) {
        log_msg(paste("HATA: PFI grafigi cizilemedi -", nm, "-", conditionMessage(e)))
        NULL
      }
    )
    if (!is.null(pfi_plot)) save_plot(pfi_plot, out_dir, "pfi_plot")
    
    summary_df <- calculate_vimp_summary(vimp_obj)
    save_vimp_summary(summary_df, out_dir)
    
    TIVM <- calculate_TIVM(summary_df)
    tivm_list[[nm]] <- TIVM
    log_msg(paste(nm, "- PFI TIVM:", round(TIVM, 4)))
  }
  
  tivm_list
}
