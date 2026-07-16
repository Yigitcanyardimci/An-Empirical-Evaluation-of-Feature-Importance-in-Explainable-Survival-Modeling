data("grace", package = "mlr3proba")

grace_data <- grace %>%
  mutate(
    revasc   = as.numeric(as.factor(revasc)),
    stchange = as.numeric(as.factor(stchange))
  ) %>%
  select(-id, -revascdays) %>%
  na.omit()

