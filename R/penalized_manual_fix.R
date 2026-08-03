# penalized paketinin predict() fonksiyonundaki bug icin manuel duzeltme.
#
# KOK NEDEN: penalized::predict.penfit(), yeni veri (newdata) uzerinde tahmin
# yaparken lineer prediktoru (lp) DOGRU hesapliyor (katsayilar dogru, X_test
# dogru), ANCAK bu lp genellikle merkezlenmemis oldugundan (ornegin "yil"
# gibi kucultulmemis/olceklenmemis bir degisken varsa) cok buyuk mutlak
# degerli olabiliyor (ornegin lp ~ -185). Paketin kendi ic Breslow taban
# hazard tahmincisi de bu merkezlenmemis lp ile kuruldugu icin sayisal olarak
# cokuyor (0 ya da 1'e yuvarlaniyor) ve sonuc olarak TUM hastalar icin
# BIREBIR AYNI (dejenere) sag kalim egrisi donduruyor - cindex=0.5.
#
# DUZELTME: egitim verisindeki lp'yi kendi ortalamasina gore merkezleyip
# (lp - mean(lp_egitim)), Breslow taban hazard tahmincisini SIFIRDAN, bu
# merkezlenmis lp ile elle kuruyoruz. Bu, standart ve iyi bilinen bir Cox
# sag kalim egrisi kurma yontemidir (paketin kendi ic hatasindan bagimsiz).

penalized_build_baseline <- function(fit, train_task) {
  betas <- fit@penalized
  fn <- names(betas)

  train_data <- as.data.frame(train_task$data(cols = fn))
  X_train <- as.matrix(train_data[, fn, drop = FALSE])
  lp_train_raw <- drop(X_train %*% betas)
  lp_center <- mean(lp_train_raw)
  lp_train_c <- lp_train_raw - lp_center

  y_train <- train_task$truth()
  time_tr   <- y_train[, 1]
  status_tr <- y_train[, 2]
  ev_times  <- sort(unique(time_tr[status_tr == 1]))

  risk_exp <- exp(lp_train_c)
  H0 <- numeric(length(ev_times))
  cumH <- 0
  for (i in seq_along(ev_times)) {
    t <- ev_times[i]
    d <- sum(time_tr == t & status_tr == 1)
    rs <- which(time_tr >= t)
    denom <- sum(risk_exp[rs])
    cumH <- cumH + d / denom
    H0[i] <- cumH
  }
  S0 <- exp(-H0)

  list(betas = betas, feature_names = fn, lp_center = lp_center,
       event_times = ev_times, S0 = S0)
}

penalized_manual_lp <- function(baseline, newdata_df) {
  X_new <- as.matrix(newdata_df[, baseline$feature_names, drop = FALSE])
  drop(X_new %*% baseline$betas) - baseline$lp_center
}

penalized_manual_survmat <- function(baseline, newdata_df, times) {
  lp_new <- penalized_manual_lp(baseline, newdata_df)
  S0_at <- sapply(times, function(t) {
    idx <- which(baseline$event_times <= t)
    if (length(idx) == 0) return(1)
    baseline$S0[max(idx)]
  })
  t(sapply(seq_along(lp_new), function(i) S0_at ^ exp(lp_new[i])))
}

# mlr3'un kendi model$predict() akisinin yerine gecen, tam bir PredictionSurv
# nesnesi kuran fonksiyon (performans olcumu icin - cindex/brier/graf/dcalib/logloss).
penalized_manual_predict_surv <- function(fit, task, row_ids, baseline) {
  sub_task <- task$clone()$filter(row_ids)
  newdata  <- as.data.frame(sub_task$data(cols = baseline$feature_names))
  y        <- sub_task$truth()
  times    <- sort(unique(task$truth()[, 1]))

  surv_mat <- penalized_manual_survmat(baseline, newdata, times)
  sr <- mlr3proba::surv_return(times = times, surv = surv_mat)

  mlr3proba::PredictionSurv$new(
    row_ids = row_ids, truth = y,
    crank = sr$crank, distr = sr$distr, lp = penalized_manual_lp(baseline, newdata)
  )
}

# survex::explain()'e gecirilecek ozel fonksiyonlar (PFI + SHAP icin).
make_penalized_survival_fn <- function(baseline) {
  force(baseline)
  function(model, newdata, times) {
    penalized_manual_survmat(baseline, newdata, times)
  }
}

make_penalized_crank_fn <- function(baseline) {
  force(baseline)
  function(model, newdata, times) {
    penalized_manual_lp(baseline, newdata)
  }
}

# measure_performance() ile ayni cikti formatini (model_completion_summary /
# performance.csv ile uyumlu) manuel PredictionSurv'den uretir. mae/mse
# (responsecompositor pipeline'i) yine paketin bozuk predict()'ine dayandigi
# icin NA birakilir - bu, pipeline'da zaten var olan "hesaplanamadi" durumuyla
# tutarlidir.
measure_performance_penalized_manual <- function(fit, task, split, model_id, baseline) {
  log_msg(paste("Performans hesaplama basladi (penalized manuel duzeltme):", model_id))
  preds <- penalized_manual_predict_surv(fit, task, split$test, baseline)

  get_score <- function(key, ...) {
    tryCatch(
      as.numeric(preds$score(msr(key), task = task, ...))[1],
      error = function(e) {
        log_msg(paste("UYARI:", key, "hesaplanamadi -", model_id, "-", conditionMessage(e)))
        NA_real_
      }
    )
  }

  sonuc <- list(
    model        = model_id,
    surv.cindex  = get_score("surv.cindex"),
    surv.dcalib  = get_score("surv.dcalib"),
    surv.brier   = get_score("surv.brier", train_set = split$train),
    surv.graf    = get_score("surv.graf", train_set = split$train),
    surv.logloss = get_score("surv.logloss"),
    surv.mae     = NA_real_,
    surv.mse     = NA_real_
  )

  log_msg(paste("Performans hesaplama bitti:", model_id,
                "- cindex:", round(sonuc$surv.cindex, 3),
                "- IBS (graf):", round(sonuc$surv.graf, 3)))
  sonuc
}
