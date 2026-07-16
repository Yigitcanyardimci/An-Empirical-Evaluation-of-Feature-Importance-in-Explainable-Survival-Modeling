# PFI hesaplar ve zaman bazli onem egrisini ozetler.

# Explainer kurar ve PFI hesaplar.
global_explain <- function(task, models, split, seed = 123) {
  log_msg("Global aciklama (PFI) basladi")
  set.seed(seed)
  
  target_names <- task$target_names
  
  test_df <- as.data.frame(task$data(rows = split$test))
  X <- test_df |> select(-all_of(target_names))
  y <- task$truth(rows = split$test)
  time_grid <- sort(unique(y[, 1]))
  
  explainers <- lapply(names(models), function(nm) {
    log_msg(paste("Explainer kuruluyor:", nm))
    tryCatch(
      survex::explain(models[[nm]], data = X, y = y, times = time_grid, label = nm),
      error = function(e) {
        log_msg(paste("HATA: explainer kurulamadi -", nm, "-", conditionMessage(e)))
        NULL
      }
    )
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

# PFI sonucunu diske kaydeder.
save_vimp <- function(vimp_obj, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "vimp.rds")
  saveRDS(vimp_obj, path)
  log_msg(paste("PFI kaydedildi:", path))
}

time_col     <- "_times_"
exclude_cols <- c(time_col, "_full_model_", "_baseline_", "_permutation_", "label", "event")

# Egri altindaki alani hesaplar.
trapz <- function(x, y) {
  o <- order(x); x <- x[o]; y <- y[o]
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2, na.rm = TRUE)
}

# PFI sonucunu uzun tabloya cevirir.
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

# Alan, gorece onem ve degiskenlik (TIV) hesaplar.
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

# Genel degiskenlik skoru (TIVM).
calculate_TIVM <- function(summary_df) {
  sum(summary_df$R_bar * summary_df$TIV, na.rm = TRUE)
}

# Ozet tabloyu diske kaydeder.
save_vimp_summary <- function(summary_df, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out_dir, "vimp_summary.csv")
  write.csv(summary_df, path, row.names = FALSE)
  log_msg(paste("PFI ozeti kaydedildi:", path))
}