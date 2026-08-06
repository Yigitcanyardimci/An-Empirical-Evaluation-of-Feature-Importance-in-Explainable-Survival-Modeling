args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Kullanim: Rscript R/00_run_dataset.R <dataset_adi> [model1,model2,...] [n_obs]")
dataset_name_arg <- args[1]
models_arg <- if (length(args) >= 2 && nzchar(args[2])) strsplit(args[2], ",")[[1]] else NULL
# n_obs: SHAP hesaplanacak gozlem sayisi. Varsayilan 15 (eski davranisla
# birebir ayni). Farkli bir n_obs verilirse, SHAP sonuclari n=15 dosyalarina
# DOKUNMADAN ayri "_n<n_obs>" dosyalarina yazilir (bkz. R/06_shap_analysis.R).
shap_n_obs <- if (length(args) >= 3 && nzchar(args[3])) as.integer(args[3]) else 15

dir.create("logs", showWarnings = FALSE)
LOG_FILE <- file.path("logs", paste0(dataset_name_arg, ".log"))

source("R/01_install_packages.R")
source("R/02_import_datasets.R")
source("R/03_modeling.R")
source("R/04_performance.R")
source("R/05_global_explain.R")
source("R/06_shap_analysis.R")
source("R/penalized_manual_fix.R")

# penalized paketinin kendi predict() fonksiyonunda, merkezlenmemis lp'den
# kaynaklanan bir bug var (bkz. R/penalized_manual_fix.R basindaki not) -
# TUM hastalar icin ayni (dejenere) sagkalim egrisi donduruyor, cindex=0.5
# oluyor. Bu SADECE su 3 veri setinde (dataDIVAT3, melanoma, rott2) gozlemlendi
# ve dogrulandi; elle Breslow taban tahmincisi kurarak duzeltiliyor.
penalized_manuel_veri_setleri <- c("dataDIVAT3", "melanoma", "rott2")

fmt <- function(x, d = 4) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("NA")
  round(x, d)
}

outputs_root <- "results"

if (!dataset_name_arg %in% names(tasks)) {
  log_msg(paste("HATA: bilinmeyen veri seti:", dataset_name_arg))
  quit(status = 1)
}
tasks <- tasks[dataset_name_arg]
if (!is.null(models_arg)) {
  model_keys <- paste0(models_arg, "_model")
  learner_specs <- learner_specs[intersect(names(learner_specs), model_keys)]
}

log_msg(paste("===== RUN (", dataset_name_arg, ") BASLADI:", length(learner_specs), "model ====="))

# Model bazinda sirali isleme: her model icin egit/yukle -> performans -> PFI -> SHAP -> BELLEKTEN SIL,
# sonra siradaki modele gec. Boylece herhangi bir anda bellekte sadece 1 modelin
# (ve o modelin explainer'inin) verisi tutulur; N model/explainer'in ayni anda
# birikmesi (eski OOM'larin ana nedeni) engellenir.
for (dataset_name in names(tasks)) {
  result <- tryCatch({
    task <- tasks[[dataset_name]]
    log_msg(paste("----- Veri seti basladi:", dataset_name, "-----"))
    log_mem(paste0("[", dataset_name, "] veri seti basi"))

    # NOT: Genel olarak N/m/max_iter'a dokunulmuyor. TEK ISTISNA: buyuk/yavas
    # 4 veri seti (nwtco, dataDIVAT3, Framingham, flchain) icin TUM veri seti
    # (model egitimi dahil) en bastan 1/3'e rastgele orneklenir - bu, kullanicinin
    # acikca onayladigi, standart "N/m/max_iter'a dokunma" kuralinin bilinçli bir
    # istisnasidir (sadece bu 4 veri seti icin, sadece hiz amacli).
    kucultulecek_veri_setleri <- c("nwtco", "dataDIVAT3", "Framingham", "flchain")
    set.seed(123)
    if (dataset_name %in% kucultulecek_veri_setleri) {
      n_orig <- task$nrow
      n_new  <- max(10, round(n_orig / 3))
      keep_rows <- sample(task$row_ids, n_new)
      task <- task$clone()$filter(keep_rows)
      log_msg(paste0("Buyuk veri seti en bastan 1/3'e indirildi: ",
                     n_orig, " -> ", n_new, " satir"))
    }

    split <- data_split(task)

    target_names <- task$target_names
    test_df <- as.data.frame(task$data(rows = split$test))
    X      <- test_df |> select(-all_of(target_names))
    y      <- task$truth(rows = split$test)
    X_test <- X   # aciklanacak gozlemler (n_obs=15) hep tam test setinden secilir, degismedi

    pfi_tivm  <- list()
    shap_tivm <- list()
    cindex_list <- list()
    basarisiz <- character(0)

    for (nm in names(learner_specs)) {
      spec    <- learner_specs[[nm]]
      out_dir <- file.path(outputs_root, spec$id, dataset_name)
      log_mem(paste0("[", dataset_name, "/", spec$id, "] model dongusu basi"))

      # 1) Model: yukle ya da egit
      model <- load_model_if_exists(out_dir)
      if (is.null(model)) {
        model <- tryCatch(
          train_one_model(task, split, spec$key, spec$id, params = spec$params),
          error = function(e) {
            log_msg(paste("HATA: model egitilemedi -", spec$id, "-", conditionMessage(e)))
            NULL
          }
        )
        if (!is.null(model)) save_model(model, out_dir)
      }

      if (is.null(model)) {
        basarisiz <- c(basarisiz, nm)
        next
      }
      log_mem(paste0("[", dataset_name, "/", spec$id, "] model hazir"))

      # 1b) penalized paketinin predict() bug'i icin manuel Breslow taban
      #     tahmincisi (sadece etkilenen 3 veri setinde, sadece penalized modeli icin)
      penalized_baseline <- NULL
      if (spec$id == "penalized" && dataset_name %in% penalized_manuel_veri_setleri) {
        train_task_pen <- task$clone()$filter(split$train)
        penalized_baseline <- tryCatch(
          penalized_build_baseline(model$model$model, train_task_pen),
          error = function(e) {
            log_msg(paste("HATA: penalized manuel baseline kurulamadi -", dataset_name, "-", conditionMessage(e)))
            NULL
          }
        )
        if (!is.null(penalized_baseline)) {
          log_msg(paste("penalized icin manuel Breslow taban tahmincisi kuruldu (predict() bug duzeltmesi):", dataset_name))
        }
      }

      # 2) Performans
      perf <- tryCatch(
        if (!is.null(penalized_baseline)) {
          measure_performance_penalized_manual(model$model$model, task, split, spec$key, penalized_baseline)
        } else {
          measure_performance(model, task, split, spec$key, params = spec$params)
        },
        error = function(e) {
          log_msg(paste("HATA: performans hesaplanamadi -", spec$id, dataset_name, "-", conditionMessage(e)))
          NULL
        }
      )
      if (!is.null(perf)) {
        save_performance(perf, out_dir)
        cindex_list[[nm]] <- perf$surv.cindex
      }

      # 3) PFI + SHAP icin explainer gerekiyor mu kontrol et
      # shap_n_obs=15 icin dosya adi eskisiyle birebir ayni (shap_summary.csv,
      # hicbir zaman silinmez/uzerine yazilmaz). Farkli n_obs icin "_n<n_obs>"
      # ekli AYRI bir dosya kullanilir (orn. shap_summary_n50.csv).
      shap_suffix <- if (shap_n_obs == 15) "" else paste0("_n", shap_n_obs)
      vimp_path <- file.path(out_dir, "vimp_summary.csv")
      shap_path <- file.path(out_dir, paste0("shap_summary", shap_suffix, ".csv"))
      vimp_done <- file.exists(vimp_path)
      shap_done <- file.exists(shap_path)

      if (vimp_done) pfi_tivm[[nm]]  <- calculate_TIVM(read.csv(vimp_path))
      if (shap_done) shap_tivm[[nm]] <- calculate_TIVM(read.csv(shap_path))

      if (vimp_done && shap_done) {
        log_msg(paste("PFI ve SHAP zaten tamam, explainer atlaniyor:", nm))
        rm(model); gc()
        log_mem(paste0("[", dataset_name, "/", spec$id, "] model silindi (PFI/SHAP zaten tamamdi)"))
        next
      }

      # 4) Explainer - TAM veri (X, y), TAM zaman izgarasi ile, TEK SEFERDE kuruluyor.
      #    N/m/max_iter'a dokunulmuyor, survex'in varsayilanlari aynen kullaniliyor.
      time_grid_full <- sort(unique(y[, 1]))
      explainer <- load_explainer_if_exists(out_dir)
      if (is.null(explainer)) {
        log_msg(paste("Explainer kuruluyor (tam veri, tam zaman izgarasi):", nm))
        explainer <- tryCatch(
          if (!is.null(penalized_baseline)) {
            survex::explain(model, data = X, y = y, times = time_grid_full, label = nm,
                             predict_survival_function = make_penalized_survival_fn(penalized_baseline),
                             predict_function = make_penalized_crank_fn(penalized_baseline),
                             verbose = FALSE)
          } else {
            survex::explain(model, data = X, y = y, times = time_grid_full, label = nm)
          },
          error = function(e) {
            log_msg(paste("HATA: explainer kurulamadi -", nm, "-", conditionMessage(e)))
            NULL
          }
        )
        if (!is.null(explainer)) save_explainer(explainer, out_dir)
      }
      log_mem(paste0("[", dataset_name, "/", spec$id, "] explainer hazir"))

      if (is.null(explainer)) {
        rm(model); gc()
        next
      }

      # 5) PFI
      if (!vimp_done) {
        log_msg(paste("PFI hesaplaniyor:", nm))
        vimp_obj <- tryCatch(
          survex::model_parts(explainer),
          error = function(e) {
            log_msg(paste("HATA: PFI hesaplanamadi -", nm, "-", conditionMessage(e)))
            NULL
          }
        )
        log_mem(paste0("[", dataset_name, "/", spec$id, "] PFI sonrasi"))
        if (!is.null(vimp_obj)) {
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
          pfi_tivm[[nm]] <- TIVM
          log_msg(paste(nm, "- PFI TIVM:", round(TIVM, 4)))
          rm(vimp_obj, summary_df, pfi_plot)
        }
      }

      # 6) SHAP - orijinal (parcasiz) fonksiyon, ayni explainer, n_obs = shap_n_obs.
      if (!shap_done) {
        log_msg(paste("SHAP hesaplaniyor:", nm, "- n_obs =", shap_n_obs))
        shap_long <- tryCatch(
          compute_survshap(explainer, X_test, out_dir, n_obs = shap_n_obs),
          error = function(e) {
            log_msg(paste("HATA: SHAP hesaplanamadi -", nm, "-", conditionMessage(e)))
            NULL
          }
        )
        log_mem(paste0("[", dataset_name, "/", spec$id, "] SHAP sonrasi"))
        if (!is.null(shap_long)) {
          shap_curve <- calculate_survshap_curve(shap_long)
          shap_plot  <- plot_survshap(shap_curve)
          save_plot(shap_plot, out_dir, paste0("survshap_plot", shap_suffix))

          shap_summary <- calculate_vimp_summary_from_long(shap_curve)
          write.csv(shap_summary, shap_path, row.names = FALSE)
          log_msg(paste("SHAP ozeti kaydedildi:", shap_path))

          TIVM <- calculate_TIVM(shap_summary)
          shap_tivm[[nm]] <- TIVM
          log_msg(paste(nm, "- SHAP TIVM:", round(TIVM, 4)))
          rm(shap_long, shap_curve, shap_summary)
        }
      }

      # 7) Bu modelin tum verisini (model + explainer) bellekten sil, siradaki modele gec
      rm(model, explainer)
      gc()
      log_mem(paste0("[", dataset_name, "/", spec$id, "] model+explainer silindi, dongu sonu"))
    }

    if (length(basarisiz) > 0) {
      log_msg(paste("UYARI: su modeller basarisiz oldu, analiz disi birakildi:",
                    paste(basarisiz, collapse = ", ")))
    }

    for (nm in names(learner_specs)) {
      if (nm %in% basarisiz) next
      model_id <- learner_specs[[nm]]$id
      cindex   <- cindex_list[[nm]]
      log_msg(paste0(
        "===== BITTI: ", dataset_name, " + ", model_id,
        " - cindex: ", fmt(cindex, 3),
        " - PFI TIVM: ", fmt(pfi_tivm[[nm]]),
        " - SHAP TIVM: ", fmt(shap_tivm[[nm]]),
        " ====="
      ))
    }

    log_msg(paste("----- Veri seti bitti:", dataset_name, "-----"))
    TRUE
  }, error = function(e) {
    log_msg(paste("KRITIK HATA:", dataset_name_arg, "-", conditionMessage(e)))
    FALSE
  })
}

log_msg(paste("===== RUN (", dataset_name_arg, ") TAMAMLANDI ====="))
