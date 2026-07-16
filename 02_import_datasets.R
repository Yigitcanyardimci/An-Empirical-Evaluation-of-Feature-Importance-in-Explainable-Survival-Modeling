# Veriyi okur ve temizler.

log_msg("Veri okuma basladi: grace")

data("grace", package = "mlr3proba")

grace_data <- grace |>
  mutate(
    revasc   = as.numeric(as.factor(revasc)),
    stchange = as.numeric(as.factor(stchange))
  ) |>
  select(-id, -revascdays) |>
  na.omit()

log_msg(paste("Veri okuma bitti: grace -", nrow(grace_data), "satir,", ncol(grace_data), "sutun"))