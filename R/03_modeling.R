# Task olusturma, split ve model egitimi.

log_msg("Task olusturuluyor: grace_task")

grace_task <- TaskSurv$new(
  id      = "grace_task",
  backend = grace_data,
  time    = "days",
  event   = "death"
)

log_msg("Task olusturuldu: grace_task")

# Veriyi train/test olarak boler.
data_split <- function(task, ratio = 0.7) {
  log_msg(paste("Split basladi (ratio =", ratio, ")"))
  set.seed(123)
  split <- partition(task, ratio = ratio)
  log_msg(paste("Split bitti - train:", length(split$train), "test:", length(split$test)))
  split
}

# Modeli egitir.
train_models <- function(task, split) {
  log_msg("Model egitimi basladi (cox)")
  set.seed(123)
  cox_model <- lrn("surv.coxph", id = "cox")
  cox_model$train(task, row_ids = split$train)
  log_msg("Model egitimi bitti (cox)")
  list(cox_model = cox_model)
}

# Modeli diske kaydeder.
save_model <- function(model, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(model, file.path(out_dir, "model.rds"))
  log_msg(paste("Model kaydedildi:", file.path(out_dir, "model.rds")))
}

# Model daha once kaydedildiyse onu okur.
load_model_if_exists <- function(out_dir) {
  path <- file.path(out_dir, "model.rds")
  if (file.exists(path)) {
    log_msg(paste("Kaydedilmis model bulundu, okunuyor:", path))
    return(readRDS(path))
  }
  log_msg("Kaydedilmis model yok, sifirdan egitilecek")
  NULL
}