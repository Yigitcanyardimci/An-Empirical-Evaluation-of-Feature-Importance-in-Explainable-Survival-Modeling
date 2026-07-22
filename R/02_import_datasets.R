# 02_import_datasets.R
library(readr)

data_dir <- "datasets"

# ---- grace ----
log_msg("Veri okuma basladi: grace")
grace_raw <- read_csv(file.path(data_dir, "grace.csv"))
grace_data <- grace_raw |>
  mutate(
    fac_revasc   = as.numeric(as.factor(fac_revasc)),
    fac_stchange = as.numeric(as.factor(fac_stchange))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: grace -", nrow(grace_data), "satir,", ncol(grace_data), "sutun"))

# ---- melanoma ----
log_msg("Veri okuma basladi: melanoma")
melanoma_raw <- read_csv(file.path(data_dir, "Melanoma.csv"))
melanoma_data <- melanoma_raw |>
  mutate(
    fac_sex   = as.numeric(as.factor(fac_sex)),
    fac_ulcer = as.numeric(as.factor(fac_ulcer))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: melanoma -", nrow(melanoma_data), "satir,", ncol(melanoma_data), "sutun"))

# ---- ova ----
log_msg("Veri okuma basladi: ova")
ova_raw <- read_csv(file.path(data_dir, "ova.csv"))
ova_data <- ova_raw |>
  mutate(
    fac_karn = as.numeric(as.factor(fac_karn)),
    fac_diam = as.numeric(as.factor(fac_diam)),
    fac_figo = as.numeric(as.factor(fac_figo))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: ova -", nrow(ova_data), "satir,", ncol(ova_data), "sutun"))

# ---- aids2 ----
log_msg("Veri okuma basladi: aids2")
aids2_raw <- read_csv(file.path(data_dir, "Aids2.csv"))
aids2_data <- aids2_raw |>
  mutate(
    fac_state   = as.numeric(as.factor(fac_state)),
    fac_sex     = as.numeric(as.factor(fac_sex)),
    fac_T_categ = as.numeric(as.factor(fac_T_categ))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: aids2 -", nrow(aids2_data), "satir,", ncol(aids2_data), "sutun"))

# ---- veteran ----
log_msg("Veri okuma basladi: veteran")
veteran_raw <- read_csv(file.path(data_dir, "veteran.csv"))
veteran_data <- veteran_raw |>
  mutate(
    fac_trt      = as.numeric(as.factor(fac_trt)),
    fac_celltype = as.numeric(as.factor(fac_celltype)),
    fac_prior    = as.numeric(as.factor(fac_prior))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: veteran -", nrow(veteran_data), "satir,", ncol(veteran_data), "sutun"))

# ---- breast ----
log_msg("Veri okuma basladi: breast")
breast_raw <- read_csv(file.path(data_dir, "breast.csv"))
breast_data <- breast_raw |>
  mutate(
    fac_TumorStage  = as.numeric(as.factor(fac_TumorStage)),
    fac_NodalStatus = as.numeric(as.factor(fac_NodalStatus)),
    fac_Histology   = as.numeric(as.factor(fac_Histology)),
    fac_CathepsinD  = as.numeric(as.factor(fac_CathepsinD))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: breast -", nrow(breast_data), "satir,", ncol(breast_data), "sutun"))

# ---- e1684 ----
log_msg("Veri okuma basladi: e1684")
e1684_raw <- read_csv(file.path(data_dir, "e1684.csv"))
e1684_data <- e1684_raw |>
  mutate(
    fac_sex = as.numeric(as.factor(fac_sex)),
    fac_trt = as.numeric(as.factor(fac_trt))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: e1684 -", nrow(e1684_data), "satir,", ncol(e1684_data), "sutun"))

# ---- epileptic ----
log_msg("Veri okuma basladi: epileptic")
epileptic_raw <- read_csv(file.path(data_dir, "epileptic.csv"))
epileptic_data <- epileptic_raw |>
  mutate(
    fac_treat     = as.numeric(as.factor(fac_treat)),
    fac_gender    = as.numeric(as.factor(fac_gender)),
    fac_learn_dis = as.numeric(as.factor(fac_learn_dis))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: epileptic -", nrow(epileptic_data), "satir,", ncol(epileptic_data), "sutun"))

# ---- dialysis ----
log_msg("Veri okuma basladi: dialysis")
dialysis_raw <- read_csv(file.path(data_dir, "Dialysis.csv"))
dialysis_data <- dialysis_raw |>
  mutate(
    fac_center  = as.numeric(as.factor(fac_center)),
    fac_disease = as.numeric(as.factor(fac_disease))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: dialysis -", nrow(dialysis_data), "satir,", ncol(dialysis_data), "sutun"))

# ---- pbc ----
log_msg("Veri okuma basladi: pbc")
pbc_raw <- read_csv(file.path(data_dir, "pbc.csv"))
pbc_data <- pbc_raw |>
  mutate(
    fac_sex     = as.numeric(as.factor(fac_sex)),
    fac_trt     = as.numeric(as.factor(fac_trt)),
    fac_ascites = as.numeric(as.factor(fac_ascites)),
    fac_hepato  = as.numeric(as.factor(fac_hepato)),
    fac_spiders = as.numeric(as.factor(fac_spiders))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: pbc -", nrow(pbc_data), "satir,", ncol(pbc_data), "sutun"))

# ---- prostateSurvival ----
log_msg("Veri okuma basladi: prostateSurvival")
prostateSurvival_raw <- read_csv(file.path(data_dir, "prostateSurvival.csv"))
prostateSurvival_data <- prostateSurvival_raw |>
  mutate(
    fac_grade    = as.numeric(as.factor(fac_grade)),
    fac_stage    = as.numeric(as.factor(fac_stage)),
    fac_ageGroup = as.numeric(as.factor(fac_ageGroup))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: prostateSurvival -", nrow(prostateSurvival_data), "satir,", ncol(prostateSurvival_data), "sutun"))

# ---- acath ----
log_msg("Veri okuma basladi: acath")
acath_raw <- read_csv(file.path(data_dir, "acath.csv"))
acath_data <- acath_raw |>
  mutate(
    fac_sex = as.numeric(as.factor(fac_sex))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: acath -", nrow(acath_data), "satir,", ncol(acath_data), "sutun"))

# ---- prostate ----
log_msg("Veri okuma basladi: prostate")
prostate_raw <- read_csv(file.path(data_dir, "prostate.csv"))
prostate_data <- prostate_raw |>
  mutate(
    fac_stage = as.numeric(as.factor(fac_stage)),
    fac_rx    = as.numeric(as.factor(fac_rx)),
    fac_pf    = as.numeric(as.factor(fac_pf)),
    fac_hx    = as.numeric(as.factor(fac_hx)),
    fac_ekg   = as.numeric(as.factor(fac_ekg)),
    fac_bm    = as.numeric(as.factor(fac_bm))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: prostate -", nrow(prostate_data), "satir,", ncol(prostate_data), "sutun"))

# ---- dataDIVAT1 ----
log_msg("Veri okuma basladi: dataDIVAT1")
dataDIVAT1_raw <- read_csv(file.path(data_dir, "dataDIVAT1.csv"))
dataDIVAT1_data <- dataDIVAT1_raw |>
  mutate(
    fac_sexR    = as.numeric(as.factor(fac_sexR)),
    fac_graft   = as.numeric(as.factor(fac_graft)),
    fac_year_tx = as.numeric(as.factor(fac_year_tx))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: dataDIVAT1 -", nrow(dataDIVAT1_data), "satir,", ncol(dataDIVAT1_data), "sutun"))

# ---- dataDIVAT3 ----
log_msg("Veri okuma basladi: dataDIVAT3")
dataDIVAT3_raw <- read_csv(file.path(data_dir, "dataDIVAT3.csv"))
dataDIVAT3_data <- dataDIVAT3_raw |>
  mutate(
    fac_sexeR     = as.numeric(as.factor(fac_sexeR)),
    fac_year_tx   = as.numeric(as.factor(fac_year_tx)),
    fac_ante_diab = as.numeric(as.factor(fac_ante_diab)),
    fac_pra       = as.numeric(as.factor(fac_pra))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: dataDIVAT3 -", nrow(dataDIVAT3_data), "satir,", ncol(dataDIVAT3_data), "sutun"))

# ---- TRACE ----
log_msg("Veri okuma basladi: TRACE")
TRACE_raw <- read_csv(file.path(data_dir, "TRACE.csv"))
TRACE_data <- TRACE_raw |>
  mutate(
    fac_sex      = as.numeric(as.factor(fac_sex)),
    fac_chf      = as.numeric(as.factor(fac_chf)),
    fac_diabetes = as.numeric(as.factor(fac_diabetes)),
    fac_vf       = as.numeric(as.factor(fac_vf))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: TRACE -", nrow(TRACE_data), "satir,", ncol(TRACE_data), "sutun"))

# ---- FRTCS ----
# NOT: time2 kolonu var, onceki calismandaki make_task_FRTCS'e gore drop ediliyor.
log_msg("Veri okuma basladi: FRTCS")
FRTCS_raw <- read_csv(file.path(data_dir, "FRTCS.csv"))
FRTCS_data <- FRTCS_raw |>
  mutate(
    fac_sex     = as.numeric(as.factor(fac_sex)),
    fac_antihyp = as.numeric(as.factor(fac_antihyp))
  ) |>
  select(-pid, -time2) |>
  na.omit()
log_msg(paste("Veri okuma bitti: FRTCS -", nrow(FRTCS_data), "satir,", ncol(FRTCS_data), "sutun"))

# ---- zinc ----
log_msg("Veri okuma basladi: zinc")
zinc_raw <- read_csv(file.path(data_dir, "zinc.csv"))
zinc_data <- zinc_raw |>
  mutate(
    fac_sex      = as.numeric(as.factor(fac_sex)),
    fac_agestr   = as.numeric(as.factor(fac_agestr)),
    fac_dysp1    = as.numeric(as.factor(fac_dysp1)),
    fac_dysp2    = as.numeric(as.factor(fac_dysp2)),
    fac_smoke    = as.numeric(as.factor(fac_smoke)),
    fac_drink    = as.numeric(as.factor(fac_drink)),
    fac_basehist = as.numeric(as.factor(fac_basehist)),
    fac_sevdysp  = as.numeric(as.factor(fac_sevdysp)),
    fac_moddysp  = as.numeric(as.factor(fac_moddysp)),
    fac_mildysp  = as.numeric(as.factor(fac_mildysp)),
    fac_zincset  = as.numeric(as.factor(fac_zincset))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: zinc -", nrow(zinc_data), "satir,", ncol(zinc_data), "sutun"))

# ---- stagec ----
log_msg("Veri okuma basladi: stagec")
stagec_raw <- read_csv(file.path(data_dir, "stagec.csv"))
stagec_data <- stagec_raw |>
  mutate(
    fac_ploidy  = as.numeric(as.factor(fac_ploidy)),
    fac_eet     = as.numeric(as.factor(fac_eet)),
    fac_grade   = as.numeric(as.factor(fac_grade)),
    fac_gleason = as.numeric(as.factor(fac_gleason))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: stagec -", nrow(stagec_data), "satir,", ncol(stagec_data), "sutun"))

# ---- LeukSurv ----
log_msg("Veri okuma basladi: LeukSurv")
LeukSurv_raw <- read_csv(file.path(data_dir, "LeukSurv.csv"))
LeukSurv_data <- LeukSurv_raw |>
  mutate(
    fac_sex      = as.numeric(as.factor(fac_sex)),
    fac_district = as.numeric(as.factor(fac_district))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: LeukSurv -", nrow(LeukSurv_data), "satir,", ncol(LeukSurv_data), "sutun"))

# ---- nwtco ----
log_msg("Veri okuma basladi: nwtco")
nwtco_raw <- read_csv(file.path(data_dir, "nwtco.csv"))
nwtco_data <- nwtco_raw |>
  mutate(
    fac_stage        = as.numeric(as.factor(fac_stage)),
    fac_study        = as.numeric(as.factor(fac_study)),
    fac_in_subcohort = as.numeric(as.factor(fac_in_subcohort)),
    fac_instit       = as.numeric(as.factor(fac_instit)),
    fac_histol       = as.numeric(as.factor(fac_histol))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: nwtco -", nrow(nwtco_data), "satir,", ncol(nwtco_data), "sutun"))

# ---- retinopathy ----
log_msg("Veri okuma basladi: retinopathy")
retinopathy_raw <- read_csv(file.path(data_dir, "retinopathy.csv"))
retinopathy_data <- retinopathy_raw |>
  mutate(
    fac_laser = as.numeric(as.factor(fac_laser)),
    fac_eye   = as.numeric(as.factor(fac_eye)),
    fac_type  = as.numeric(as.factor(fac_type)),
    fac_trt   = as.numeric(as.factor(fac_trt)),
    fac_risk  = as.numeric(as.factor(fac_risk))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: retinopathy -", nrow(retinopathy_data), "satir,", ncol(retinopathy_data), "sutun"))

# ---- Framingham ----
log_msg("Veri okuma basladi: Framingham")
Framingham_raw <- read_csv(file.path(data_dir, "Framingham.csv"))
Framingham_data <- Framingham_raw |>
  mutate(
    fac_sex   = as.numeric(as.factor(fac_sex)),
    fac_month = as.numeric(as.factor(fac_month))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: Framingham -", nrow(Framingham_data), "satir,", ncol(Framingham_data), "sutun"))

# ---- csl ----
# NOT: time2 kolonu var, onceki calismandaki make_task_csl'e gore drop ediliyor.
log_msg("Veri okuma basladi: csl")
csl_raw <- read_csv(file.path(data_dir, "csl.csv"))
csl_data <- csl_raw |>
  mutate(
    fac_sex   = as.numeric(as.factor(fac_sex)),
    fac_treat = as.numeric(as.factor(fac_treat))
  ) |>
  select(-pid, -time2) |>
  na.omit()
log_msg(paste("Veri okuma bitti: csl -", nrow(csl_data), "satir,", ncol(csl_data), "sutun"))

# ---- cancer ----
log_msg("Veri okuma basladi: cancer")
cancer_raw <- read_csv(file.path(data_dir, "cancer.csv"))
cancer_data <- cancer_raw |>
  mutate(
    fac_inst    = as.numeric(as.factor(fac_inst)),
    fac_ph_ecog = as.numeric(as.factor(fac_ph_ecog)),
    fac_sex     = as.numeric(as.factor(fac_sex))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: cancer -", nrow(cancer_data), "satir,", ncol(cancer_data), "sutun"))

# ---- whas500 ----
log_msg("Veri okuma basladi: whas500")
whas500_raw <- read_csv(file.path(data_dir, "whas500.csv"))
whas500_data <- whas500_raw |>
  mutate(
    fac_gender = as.numeric(as.factor(fac_gender)),
    fac_cvd    = as.numeric(as.factor(fac_cvd)),
    fac_afb    = as.numeric(as.factor(fac_afb)),
    fac_sho    = as.numeric(as.factor(fac_sho)),
    fac_chf    = as.numeric(as.factor(fac_chf)),
    fac_av3    = as.numeric(as.factor(fac_av3)),
    fac_miord  = as.numeric(as.factor(fac_miord)),
    fac_mitype = as.numeric(as.factor(fac_mitype)),
    fac_year   = as.numeric(as.factor(fac_year))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: whas500 -", nrow(whas500_data), "satir,", ncol(whas500_data), "sutun"))

# ---- cgd ----
log_msg("Veri okuma basladi: cgd")
cgd_raw <- read_csv(file.path(data_dir, "cgd.csv"))
cgd_data <- cgd_raw |>
  mutate(
    fac_center   = as.numeric(as.factor(fac_center)),
    fac_treat    = as.numeric(as.factor(fac_treat)),
    fac_sex      = as.numeric(as.factor(fac_sex)),
    fac_inherit  = as.numeric(as.factor(fac_inherit)),
    fac_steroids = as.numeric(as.factor(fac_steroids)),
    fac_propylac = as.numeric(as.factor(fac_propylac)),
    fac_hos_cat  = as.numeric(as.factor(fac_hos_cat))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: cgd -", nrow(cgd_data), "satir,", ncol(cgd_data), "sutun"))

# ---- Pbc3 ----
log_msg("Veri okuma basladi: Pbc3")
Pbc3_raw <- read_csv(file.path(data_dir, "Pbc3.csv"))
Pbc3_data <- Pbc3_raw |>
  mutate(
    fac_unit    = as.numeric(as.factor(fac_unit)),
    fac_tment   = as.numeric(as.factor(fac_tment)),
    fac_sex     = as.numeric(as.factor(fac_sex)),
    fac_stage   = as.numeric(as.factor(fac_stage)),
    fac_gibleed = as.numeric(as.factor(fac_gibleed))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: Pbc3 -", nrow(Pbc3_data), "satir,", ncol(Pbc3_data), "sutun"))

# ---- GBSG2 ----
log_msg("Veri okuma basladi: GBSG2")
GBSG2_raw <- read_csv(file.path(data_dir, "GBSG2.csv"))
GBSG2_data <- GBSG2_raw |>
  mutate(
    fac_horTh    = as.numeric(as.factor(fac_horTh)),
    fac_menostat = as.numeric(as.factor(fac_menostat)),
    fac_tgrade   = as.numeric(as.factor(fac_tgrade))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: GBSG2 -", nrow(GBSG2_data), "satir,", ncol(GBSG2_data), "sutun"))

# ---- colon ----
log_msg("Veri okuma basladi: colon")
colon_raw <- read_csv(file.path(data_dir, "colon.csv"))
colon_data <- colon_raw |>
  mutate(
    fac_rx       = as.numeric(as.factor(fac_rx)),
    fac_sex      = as.numeric(as.factor(fac_sex)),
    fac_differ   = as.numeric(as.factor(fac_differ)),
    fac_obstruct = as.numeric(as.factor(fac_obstruct)),
    fac_perfor   = as.numeric(as.factor(fac_perfor)),
    fac_adhere   = as.numeric(as.factor(fac_adhere)),
    fac_node4    = as.numeric(as.factor(fac_node4))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: colon -", nrow(colon_data), "satir,", ncol(colon_data), "sutun"))

# ---- flchain ----
log_msg("Veri okuma basladi: flchain")
flchain_raw <- read_csv(file.path(data_dir, "flchain.csv"))
flchain_data <- flchain_raw |>
  mutate(
    fac_sex       = as.numeric(as.factor(fac_sex)),
    fac_chapter   = as.numeric(as.factor(fac_chapter)),
    fac_sample_yr = as.numeric(as.factor(fac_sample_yr)),
    fac_mgus      = as.numeric(as.factor(fac_mgus))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: flchain -", nrow(flchain_data), "satir,", ncol(flchain_data), "sutun"))

# ---- Rossi ----
# NOT: time2 kolonu var, onceki calismandaki make_task_Rossi'e gore drop ediliyor.
log_msg("Veri okuma basladi: Rossi")
Rossi_raw <- read_csv(file.path(data_dir, "Rossi.csv"))
Rossi_data <- Rossi_raw |>
  mutate(
    fac_fin  = as.numeric(as.factor(fac_fin)),
    fac_race = as.numeric(as.factor(fac_race)),
    fac_wexp = as.numeric(as.factor(fac_wexp)),
    fac_mar  = as.numeric(as.factor(fac_mar)),
    fac_paro = as.numeric(as.factor(fac_paro)),
    fac_prio = as.numeric(as.factor(fac_prio)),
    fac_educ = as.numeric(as.factor(fac_educ)),
    fac_emp  = as.numeric(as.factor(fac_emp))
  ) |>
  select(-pid, -time2) |>
  na.omit()
log_msg(paste("Veri okuma bitti: Rossi -", nrow(Rossi_data), "satir,", ncol(Rossi_data), "sutun"))

# ---- burn ----
log_msg("Veri okuma basladi: burn")
burn_raw <- read_csv(file.path(data_dir, "burn.csv"))
burn_data <- burn_raw |>
  mutate(
    fac_burn_buttock   = as.numeric(as.factor(fac_burn_buttock)),
    fac_burn_head      = as.numeric(as.factor(fac_burn_head)),
    fac_burn_lower_leg = as.numeric(as.factor(fac_burn_lower_leg)),
    fac_burn_resp      = as.numeric(as.factor(fac_burn_resp)),
    fac_burn_trunk     = as.numeric(as.factor(fac_burn_trunk)),
    fac_burn_type      = as.numeric(as.factor(fac_burn_type)),
    fac_burn_upper_leg = as.numeric(as.factor(fac_burn_upper_leg)),
    fac_race           = as.numeric(as.factor(fac_race)),
    fac_sex            = as.numeric(as.factor(fac_sex)),
    fac_treatment      = as.numeric(as.factor(fac_treatment))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: burn -", nrow(burn_data), "satir,", ncol(burn_data), "sutun"))

# ---- rott2 ----
log_msg("Veri okuma basladi: rott2")
rott2_raw <- read_csv(file.path(data_dir, "rott2.csv"))
rott2_data <- rott2_raw |>
  mutate(
    fac_meno   = as.numeric(as.factor(fac_meno)),
    fac_tsize  = as.numeric(as.factor(fac_tsize)),
    fac_grade  = as.numeric(as.factor(fac_grade)),
    fac_hormon = as.numeric(as.factor(fac_hormon)),
    fac_chemo  = as.numeric(as.factor(fac_chemo)),
    fac_recent = as.numeric(as.factor(fac_recent))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: rott2 -", nrow(rott2_data), "satir,", ncol(rott2_data), "sutun"))

# ---- d_oropha_rec ----
log_msg("Veri okuma basladi: d_oropha_rec")
d_oropha_rec_raw <- read_csv(file.path(data_dir, "d.oropha.rec.csv"))
d_oropha_rec_data <- d_oropha_rec_raw |>
  mutate(
    fac_inst   = as.numeric(as.factor(fac_inst)),
    fac_sex    = as.numeric(as.factor(fac_sex)),
    fac_treatm = as.numeric(as.factor(fac_treatm)),
    fac_grade  = as.numeric(as.factor(fac_grade)),
    fac_cond   = as.numeric(as.factor(fac_cond)),
    fac_site   = as.numeric(as.factor(fac_site)),
    fac_tstage = as.numeric(as.factor(fac_tstage)),
    fac_nstage = as.numeric(as.factor(fac_nstage))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: d_oropha_rec -", nrow(d_oropha_rec_data), "satir,", ncol(d_oropha_rec_data), "sutun"))

# ---- rdata ----
log_msg("Veri okuma basladi: rdata")
rdata_raw <- read_csv(file.path(data_dir, "rdata.csv"))
rdata_data <- rdata_raw |>
  mutate(
    fac_sex   = as.numeric(as.factor(fac_sex)),
    fac_agegr = as.numeric(as.factor(fac_agegr))
  ) |>
  select(-pid) |>
  na.omit()
log_msg(paste("Veri okuma bitti: rdata -", nrow(rdata_data), "satir,", ncol(rdata_data), "sutun"))
