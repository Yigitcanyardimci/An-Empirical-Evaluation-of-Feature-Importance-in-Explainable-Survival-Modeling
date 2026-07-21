# 03_modeling.R
log_msg("Task olusturuluyor: grace_task")
grace_task <- TaskSurv$new(id = "grace_task", backend = grace_data, time = "time", event = "event")
log_msg("Task olusturuldu: grace_task")

log_msg("Task olusturuluyor: melanoma_task")
melanoma_task <- TaskSurv$new(id = "melanoma_task", backend = melanoma_data, time = "time", event = "event")
log_msg("Task olusturuldu: melanoma_task")

log_msg("Task olusturuluyor: ova_task")
ova_task <- TaskSurv$new(id = "ova_task", backend = ova_data, time = "time", event = "event")
log_msg("Task olusturuldu: ova_task")

log_msg("Task olusturuluyor: aids2_task")
aids2_task <- TaskSurv$new(id = "aids2_task", backend = aids2_data, time = "time", event = "event")
log_msg("Task olusturuldu: aids2_task")

log_msg("Task olusturuluyor: veteran_task")
veteran_task <- TaskSurv$new(id = "veteran_task", backend = veteran_data, time = "time", event = "event")
log_msg("Task olusturuldu: veteran_task")

log_msg("Task olusturuluyor: breast_task")
breast_task <- TaskSurv$new(id = "breast_task", backend = breast_data, time = "time", event = "event")
log_msg("Task olusturuldu: breast_task")

log_msg("Task olusturuluyor: e1684_task")
e1684_task <- TaskSurv$new(id = "e1684_task", backend = e1684_data, time = "time", event = "event")
log_msg("Task olusturuldu: e1684_task")

log_msg("Task olusturuluyor: epileptic_task")
epileptic_task <- TaskSurv$new(id = "epileptic_task", backend = epileptic_data, time = "time", event = "event")
log_msg("Task olusturuldu: epileptic_task")

log_msg("Task olusturuluyor: dialysis_task")
dialysis_task <- TaskSurv$new(id = "dialysis_task", backend = dialysis_data, time = "time", event = "event")
log_msg("Task olusturuldu: dialysis_task")

log_msg("Task olusturuluyor: pbc_task")
pbc_task <- TaskSurv$new(id = "pbc_task", backend = pbc_data, time = "time", event = "event")
log_msg("Task olusturuldu: pbc_task")

log_msg("Task olusturuluyor: prostateSurvival_task")
prostateSurvival_task <- TaskSurv$new(id = "prostateSurvival_task", backend = prostateSurvival_data, time = "time", event = "event")
log_msg("Task olusturuldu: prostateSurvival_task")

log_msg("Task olusturuluyor: acath_task")
acath_task <- TaskSurv$new(id = "acath_task", backend = acath_data, time = "time", event = "event")
log_msg("Task olusturuldu: acath_task")

log_msg("Task olusturuluyor: prostate_task")
prostate_task <- TaskSurv$new(id = "prostate_task", backend = prostate_data, time = "time", event = "event")
log_msg("Task olusturuldu: prostate_task")

log_msg("Task olusturuluyor: dataDIVAT1_task")
dataDIVAT1_task <- TaskSurv$new(id = "dataDIVAT1_task", backend = dataDIVAT1_data, time = "time", event = "event")
log_msg("Task olusturuldu: dataDIVAT1_task")

log_msg("Task olusturuluyor: dataDIVAT3_task")
dataDIVAT3_task <- TaskSurv$new(id = "dataDIVAT3_task", backend = dataDIVAT3_data, time = "time", event = "event")
log_msg("Task olusturuldu: dataDIVAT3_task")

log_msg("Task olusturuluyor: TRACE_task")
TRACE_task <- TaskSurv$new(id = "TRACE_task", backend = TRACE_data, time = "time", event = "event")
log_msg("Task olusturuldu: TRACE_task")

log_msg("Task olusturuluyor: FRTCS_task")
FRTCS_task <- TaskSurv$new(id = "FRTCS_task", backend = FRTCS_data, time = "time", event = "event")
log_msg("Task olusturuldu: FRTCS_task")

log_msg("Task olusturuluyor: zinc_task")
zinc_task <- TaskSurv$new(id = "zinc_task", backend = zinc_data, time = "time", event = "event")
log_msg("Task olusturuldu: zinc_task")

log_msg("Task olusturuluyor: stagec_task")
stagec_task <- TaskSurv$new(id = "stagec_task", backend = stagec_data, time = "time", event = "event")
log_msg("Task olusturuldu: stagec_task")

log_msg("Task olusturuluyor: LeukSurv_task")
LeukSurv_task <- TaskSurv$new(id = "LeukSurv_task", backend = LeukSurv_data, time = "time", event = "event")
log_msg("Task olusturuldu: LeukSurv_task")

log_msg("Task olusturuluyor: nwtco_task")
nwtco_task <- TaskSurv$new(id = "nwtco_task", backend = nwtco_data, time = "time", event = "event")
log_msg("Task olusturuldu: nwtco_task")

log_msg("Task olusturuluyor: retinopathy_task")
retinopathy_task <- TaskSurv$new(id = "retinopathy_task", backend = retinopathy_data, time = "time", event = "event")
log_msg("Task olusturuldu: retinopathy_task")

log_msg("Task olusturuluyor: Framingham_task")
Framingham_task <- TaskSurv$new(id = "Framingham_task", backend = Framingham_data, time = "time", event = "event")
log_msg("Task olusturuldu: Framingham_task")

log_msg("Task olusturuluyor: csl_task")
csl_task <- TaskSurv$new(id = "csl_task", backend = csl_data, time = "time", event = "event")
log_msg("Task olusturuldu: csl_task")

log_msg("Task olusturuluyor: cancer_task")
cancer_task <- TaskSurv$new(id = "cancer_task", backend = cancer_data, time = "time", event = "event")
log_msg("Task olusturuldu: cancer_task")

log_msg("Task olusturuluyor: whas500_task")
whas500_task <- TaskSurv$new(id = "whas500_task", backend = whas500_data, time = "time", event = "event")
log_msg("Task olusturuldu: whas500_task")

log_msg("Task olusturuluyor: cgd_task")
cgd_task <- TaskSurv$new(id = "cgd_task", backend = cgd_data, time = "time", event = "event")
log_msg("Task olusturuldu: cgd_task")

log_msg("Task olusturuluyor: Pbc3_task")
Pbc3_task <- TaskSurv$new(id = "Pbc3_task", backend = Pbc3_data, time = "time", event = "event")
log_msg("Task olusturuldu: Pbc3_task")

log_msg("Task olusturuluyor: GBSG2_task")
GBSG2_task <- TaskSurv$new(id = "GBSG2_task", backend = GBSG2_data, time = "time", event = "event")
log_msg("Task olusturuldu: GBSG2_task")

log_msg("Task olusturuluyor: colon_task")
colon_task <- TaskSurv$new(id = "colon_task", backend = colon_data, time = "time", event = "event")
log_msg("Task olusturuldu: colon_task")

log_msg("Task olusturuluyor: flchain_task")
flchain_task <- TaskSurv$new(id = "flchain_task", backend = flchain_data, time = "time", event = "event")
log_msg("Task olusturuldu: flchain_task")

log_msg("Task olusturuluyor: Rossi_task")
Rossi_task <- TaskSurv$new(id = "Rossi_task", backend = Rossi_data, time = "time", event = "event")
log_msg("Task olusturuldu: Rossi_task")

log_msg("Task olusturuluyor: burn_task")
burn_task <- TaskSurv$new(id = "burn_task", backend = burn_data, time = "time", event = "event")
log_msg("Task olusturuldu: burn_task")

log_msg("Task olusturuluyor: rott2_task")
rott2_task <- TaskSurv$new(id = "rott2_task", backend = rott2_data, time = "time", event = "event")
log_msg("Task olusturuldu: rott2_task")

log_msg("Task olusturuluyor: d_oropha_rec_task")
d_oropha_rec_task <- TaskSurv$new(id = "d_oropha_rec_task", backend = d_oropha_rec_data, time = "time", event = "event")
log_msg("Task olusturuldu: d_oropha_rec_task")

log_msg("Task olusturuluyor: rdata_task")
rdata_task <- TaskSurv$new(id = "rdata_task", backend = rdata_data, time = "time", event = "event")
log_msg("Task olusturuldu: rdata_task")

# Tum tasklari tek yerde toplayan liste. 07_run_all.R bunun uzerinde donuyor.
tasks <- list(
  grace            = grace_task,
  melanoma         = melanoma_task,
  ova              = ova_task,
  aids2            = aids2_task,
  veteran          = veteran_task,
  breast           = breast_task,
  e1684            = e1684_task,
  epileptic        = epileptic_task,
  dialysis         = dialysis_task,
  pbc              = pbc_task,
  prostateSurvival = prostateSurvival_task,
  acath            = acath_task,
  prostate         = prostate_task,
  dataDIVAT1       = dataDIVAT1_task,
  dataDIVAT3       = dataDIVAT3_task,
  TRACE            = TRACE_task,
  FRTCS            = FRTCS_task,
  zinc             = zinc_task,
  stagec           = stagec_task,
  LeukSurv         = LeukSurv_task,
  nwtco            = nwtco_task,
  retinopathy      = retinopathy_task,
  Framingham       = Framingham_task,
  csl              = csl_task,
  cancer           = cancer_task,
  whas500          = whas500_task,
  cgd              = cgd_task,
  Pbc3             = Pbc3_task,
  GBSG2            = GBSG2_task,
  colon            = colon_task,
  flchain          = flchain_task,
  Rossi            = Rossi_task,
  burn             = burn_task,
  rott2            = rott2_task,
  d_oropha_rec     = d_oropha_rec_task,
  rdata            = rdata_task
)
log_msg(paste("Toplam", length(tasks), "task olusturuldu"))

data_split <- function(task, ratio = 0.7) {
  log_msg(paste("Split basladi (ratio =", ratio, ")"))
  set.seed(123)
  split <- partition(task, ratio = ratio)
  log_msg(paste("Split bitti - train:", length(split$train), "test:", length(split$test)))
  split
}

learner_specs <- list(
  cox_model         = list(key = "surv.coxph",       id = "cox"),
  aorsf_model       = list(key = "surv.aorsf",        id = "aorsf"),
  cforest_model     = list(key = "surv.cforest",      id = "cforest"),
  coxboost_model    = list(key = "surv.coxboost",     id = "coxboost"),
  cv_coxboost_model = list(key = "surv.cv_coxboost",  id = "cv_coxboost"),
  ctree_model       = list(key = "surv.ctree",        id = "ctree"),
  cv_glmnet_model   = list(key = "surv.cv_glmnet",    id = "cv_glmnet"),
  glmboost_model    = list(key = "surv.glmboost",     id = "glmboost"),
  glmnet_model      = list(key = "surv.glmnet",       id = "glmnet"),
  penalized_model   = list(key = "surv.penalized",    id = "penalized"),
  ranger_model      = list(key = "surv.ranger",       id = "ranger"),
  rfsrc_model       = list(key = "surv.rfsrc",        id = "rfsrc"),
  xgboost_cox_model = list(key = "surv.xgboost.cox",  id = "xgboost_cox")
)

train_one_model <- function(task, split, learner_key, learner_id) {
  log_msg(paste("Model egitimi basladi (", learner_id, ")"))
  set.seed(123)
  model <- lrn(learner_key, id = learner_id)
  
  if ("distr" %in% model$predict_types) {
    model$predict_type <- "distr"
  } else {
    log_msg(paste("UYARI:", learner_id, "- 'distr' predict type desteklenmiyor, PFI/SHAP bu model icin hesaplanamayacak"))
  }
  
  model$train(task, row_ids = split$train)
  log_msg(paste("Model egitimi bitti (", learner_id, ")"))
  model
}

save_model <- function(model, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(model, file.path(out_dir, "model.rds"))
  log_msg(paste("Model kaydedildi:", file.path(out_dir, "model.rds")))
}

load_model_if_exists <- function(out_dir) {
  path <- file.path(out_dir, "model.rds")
  if (file.exists(path)) {
    log_msg(paste("Kaydedilmis model bulundu, okunuyor:", path))
    return(readRDS(path))
  }
  log_msg("Kaydedilmis model yok, sifirdan egitilecek")
  NULL
}

train_or_load_models <- function(task, split, dataset_name, outputs_root = "outputs") {
  models    <- list()
  basarisiz <- character(0)
  
  for (nm in names(learner_specs)) {
    spec    <- learner_specs[[nm]]
    out_dir <- file.path(outputs_root, spec$id, dataset_name)
    
    model <- load_model_if_exists(out_dir)
    if (is.null(model)) {
      model <- tryCatch(
        train_one_model(task, split, spec$key, spec$id),
        error = function(e) {
          log_msg(paste("HATA: model egitilemedi -", spec$id, "-", conditionMessage(e)))
          NULL
        }
      )
      if (!is.null(model)) save_model(model, out_dir)
    }
    
    if (is.null(model)) {
      basarisiz <- c(basarisiz, nm)
    } else {
      models[[nm]] <- model
    }
  }
  
  if (length(basarisiz) > 0) {
    log_msg(paste("UYARI: su modeller basarisiz oldu, analiz disi birakildi:",
                  paste(basarisiz, collapse = ", ")))
  }
  
  models
}
