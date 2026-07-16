time_col     <- "_times_"
exclude_cols <- c(time_col, "_full_model_", "_baseline_", "_permutation_", "label", "event")

trapz <- function(x, y) {
  o <- order(x); x <- x[o]; y <- y[o]
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2, na.rm = TRUE)
}

vimp_to_long <- function(vimp_obj) {
  res       <- as.data.frame(vimp_obj$result)
  vimp_vars <- setdiff(names(res), exclude_cols)
  
  long_raw <- res %>%
    select(all_of(c(time_col, vimp_vars))) %>%
    pivot_longer(-all_of(time_col), names_to = "variable", values_to = "fj_t")

  long_raw %>%
    group_by(variable, .data[[time_col]]) %>%
    summarise(fj_t = mean(fj_t, na.rm = TRUE), .groups = "drop") %>%
    arrange(variable, .data[[time_col]])
}

calculate_vimp_summary_from_long <- function(long_df) {
  long_df %>%
    group_by(variable) %>%
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
    ) %>%
    mutate(R_bar = A_bar / sum(A_bar, na.rm = TRUE)) %>%
    arrange(desc(R_bar))
}

calculate_vimp_summary <- function(vimp_obj) {
  calculate_vimp_summary_from_long(vimp_to_long(vimp_obj))
}

calculate_TIVM <- function(summary_df) {
  sum(summary_df$R_bar * summary_df$TIV, na.rm = TRUE)
}