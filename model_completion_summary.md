# Model Tamamlanma Özeti (Tüm 36 Veri Seti)

Hedef: veri seti başına 11 model (cox, cforest, coxboost, ctree, cv_glmnet, glmboost, glmnet, penalized, ranger, rfsrc, xgboost_cox)

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
| 27 | rott2 | 11/11 | **0/11** | **0/11** | Modeller eğitildi, PFI/SHAP hiç hesaplanmadı |
| 28 | stagec | 11/11 | 11/11 | 11/11 | - |
| 29 | TRACE | 11/11 | 11/11 | 11/11 | - |
| 30 | veteran | 11/11 | 11/11 | 11/11 | - |
| 31 | whas500 | 11/11 | 11/11 | 11/11 | - |
| 32 | zinc | 11/11 | 11/11 | 11/11 | - |
| **—** | **Devam eden veri setleri (bellek/OOM sorunu, SHAP aşamasında takılı)** | | | | |
| 33 | nwtco | var | var | **yok** | - |
| 34 | dataDIVAT3 | var | var | **yok** | - |
| 35 | Framingham | var | var | **yok** | - |
| 36 | flchain | var | var | **yok** | - |

**Toplam (1-32, hedef 352):**
- Performans: **331 / 352**
- PFI: **320 / 352**
- SHAP: **319 / 352**

**33-36:** Performans ve PFI çoğu modelde var, SHAP hiçbirinde yok.

*Not: rott2'de modeller eğitilip performans metrikleri hesaplanmış ama PFI/SHAP hiç çalıştırılmamış (log dosyası yanlışlıkla "TAMAMLANDI" göstermiş). "Hiç eğitilemedi" notu olan modeller, o veri setinde zaman değişkeninde ≤0 değer olması (cv_glmnet/glmnet) veya paket bağımlılığı eksikliği (cforest/ctree: coin paketi) gibi veri/ortam kaynaklı sorunlardır.*
