# Paket eksikse kurar, varsa direkt kullanir.

log_msg <- function(msg) {
  satir <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", msg)
  cat(satir, "\n")
  cat(satir, "\n", file = "calisma.log", append = TRUE)
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

invisible(lapply(c(required_pkgs, "mlr3proba"), library, character.only = TRUE))

log_msg("Paket kurulumu tamamlandi")