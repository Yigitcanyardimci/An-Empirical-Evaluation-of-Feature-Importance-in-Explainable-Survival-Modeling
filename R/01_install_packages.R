# 01_install_packages.R
if (!exists("LOG_FILE")) LOG_FILE <- "calisma.log"
log_msg <- function(msg) {
  satir <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", msg)
  cat(satir, "\n")
  cat(satir, "\n", file = LOG_FILE, append = TRUE)
}
log_msg("Paket kurulumu basladi")

if (file.exists("renv.lock")) {
  log_msg("renv.lock bulundu, renv::restore() calistiriliyor")
  if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
  renv::restore(prompt = FALSE)
  log_msg("renv::restore() tamamlandi")
} else {
  log_msg("renv.lock bulunamadi, normal kurulum yapiliyor")
  message("renv.lock bulunamadi, normal kurulum yapiliyor. ",
          "Reproducibility icin projede bir kere renv::init() calistirabilirsin.")
}

required_pkgs <- c(
  "dplyr", "tidyr", "survival", "mlr3", "mlr3pipelines",
  "survex", "ggplot2", "remotes"
)
eksik <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(eksik) > 0) {
  log_msg(paste("Eksik paketler kuruluyor:", paste(eksik, collapse = ", ")))
  install.packages(eksik)
}

if (!requireNamespace("mlr3proba", quietly = TRUE)) {
  log_msg("mlr3proba GitHub'dan kuruluyor")
  remotes::install_github("mlr-org/mlr3proba", force = TRUE)
}

if (!requireNamespace("mlr3extralearners", quietly = TRUE)) {
  log_msg("mlr3extralearners GitHub'dan kuruluyor")
  remotes::install_github("mlr-org/mlr3extralearners", force = TRUE)
}

if (!requireNamespace("CoxBoost", quietly = TRUE)) {
  log_msg("CoxBoost GitHub'dan kuruluyor")
  remotes::install_github("binderh/CoxBoost", force = TRUE)
}

invisible(lapply(c(required_pkgs, "mlr3proba", "mlr3extralearners", "CoxBoost"), library, character.only = TRUE))

extra_learner_keys <- c(
  "surv.aorsf", "surv.cforest", "surv.coxboost", "surv.cv_coxboost",
  "surv.ctree", "surv.cv_glmnet", "surv.glmboost", "surv.glmnet", "surv.penalized",
  "surv.ranger", "surv.rfsrc", "surv.xgboost.cox", "surv.gamboost", "surv.mboost"
)
log_msg("Extralearner bagimliliklari kontrol ediliyor / kuruluyor")
tryCatch(
  mlr3extralearners::install_learners(extra_learner_keys),
  error = function(e) log_msg(paste("UYARI: install_learners basarisiz -", conditionMessage(e)))
)

log_msg("Paket kurulumu tamamlandi")
