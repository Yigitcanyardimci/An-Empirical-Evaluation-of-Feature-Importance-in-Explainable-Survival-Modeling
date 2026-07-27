# Model Tamamlanma Özeti (Tüm 36 Veri Seti)

| # | Veri Seti | Performans | PFI | SHAP | Not |
|---|---|---|---|---|---|
| 1 | acath | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 2 | aids2 | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 3 | breast | 11/11 | 11/11 | 11/11 | - |
| 4 | burn | 11/11 | 11/11 | 11/11 | - |
| 5 | cancer | 11/11 | 11/11 | 11/11 | - |
| 6 | cgd | 11/11 | 11/11 | 11/11 | - |
| 7 | colon | 11/11 | 11/11 | 10/11 | xgboost_cox: SHAP eksik |
| 8 | csl | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 9 | d_oropha_rec | 10/11 | 10/11 | 10/11 | penalized hiç eğitilemedi |
| 10 | dataDIVAT1 | 11/11 | 11/11 | 11/11 | - |
| 11 | dialysis | 9/11 | 9/11 | 9/11 | cforest, ctree hiç eğitilemedi |
| 12 | e1684 | 11/11 | 11/11 | 11/11 | - |
| 13 | epileptic | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 14 | FRTCS | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 15 | GBSG2 | 11/11 | 11/11 | 11/11 | - |
| 16 | grace | 11/11 | 11/11 | 11/11 | - |
| 17 | LeukSurv | 11/11 | 11/11 | 11/11 | - |
| 18 | melanoma | 11/11 | 11/11 | 11/11 | - |
| 19 | ova | 11/11 | 11/11 | 11/11 | - |
| 20 | pbc | 11/11 | 11/11 | 11/11 | - |
| 21 | Pbc3 | 11/11 | 11/11 | 11/11 | - |
| 22 | prostate | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 23 | prostateSurvival | 7/11 | 7/11 | 7/11 | cforest, ctree, cv_glmnet, glmnet hiç eğitilemedi |
| 24 | rdata | 11/11 | 11/11 | 11/11 | - |
| 25 | retinopathy | 11/11 | 11/11 | 11/11 | - |
| 26 | Rossi | 9/11 | 9/11 | 9/11 | cv_glmnet, glmnet hiç eğitilemedi |
| 27 | rott2 | 11/11 | 0/11 | 0/11 | Modeller eğitildi, PFI/SHAP hiç hesaplanmadı |
| 28 | stagec | 11/11 | 11/11 | 11/11 | - |
| 29 | TRACE | 11/11 | 11/11 | 11/11 | - |
| 30 | veteran | 11/11 | 11/11 | 11/11 | - |
| 31 | whas500 | 11/11 | 11/11 | 11/11 | - |
| 32 | zinc | 11/11 | 11/11 | 11/11 | - |
| **—** | **Devam eden veri setleri (bellek/OOM sorunu, SHAP aşamasında takılı)** | | | | |
| 33 | nwtco | var | var | yok | penalized hiç eğitilemedi. SHAP sadece cox'ta tamamlandı |
| 34 | dataDIVAT3 | var | var | yok | SHAP: cox, cforest, coxboost, ctree tamamlandı |
| 35 | Framingham | var | var | yok | SHAP hiç başlamadı |
| 36 | flchain | var | var | yok | cv_glmnet, glmnet hiç eğitilemedi. SHAP hiç başlamadı |

**1-32 (hedef 352):** Performans 331/352 | PFI 320/352 | SHAP 319/352
**33-36:** Performans ve PFI çoğu modelde var, SHAP hiçbirinde yok

---

**11 model neyi ifade ediyor:** Her veri seti için hedeflenen 11 model şöyle:

- **cox** — Cox regresyon
- **cforest** — conditional random forest
- **coxboost** — gradient boosting (Cox)
- **ctree** — conditional inference tree
- **cv_glmnet** — cross-validated elastic net
- **glmboost** — gradient boosting (GLM)
- **glmnet** — elastic net
- **penalized** — penalized Cox
- **ranger** — random survival forest
- **rfsrc** — random survival forest (alternatif implementasyon)
- **xgboost_cox** — XGBoost (Cox)

Örneğin "9/11" bu 11 modelden 9'unun başarıyla çalıştığı anlamına gelir.

**Notlar:** acath, aids2, csl, epileptic, FRTCS, prostate, Rossi: cv_glmnet ve glmnet hiç eğitilemedi (zaman değişkeninde ≤0 değer var). dialysis: cforest ve ctree hiç eğitilemedi (coin paketi yüklenemedi). d_oropha_rec: penalized hiç eğitilemedi (matris tersi alınamadı). prostateSurvival: cforest, ctree, cv_glmnet, glmnet hiç eğitilemedi. colon: xgboost_cox'ta SHAP eksik. rott2: modeller eğitilip performans hesaplanmış ama PFI/SHAP hiç çalıştırılmamış (log dosyası yanlışlıkla "TAMAMLANDI" göstermiş). flchain: cv_glmnet ve glmnet hiç eğitilemedi. 33-36 (nwtco, dataDIVAT3, Framingham, flchain), pipeline'in bellek (OOM) sorunu nedeniyle SHAP aşamasında takılı kalan, henüz tamamlanmamış veri setleridir.
