
# Survival-XAI

## An Empirical Evaluation of Feature Importance in Explainable Survival Modeling

Bu çalışma, survival analizinde global değişken önemi açıklamalarının tutarlılığını, sayısal kararlılığını ve zamansal davranışını ampirik olarak incelemektedir.

Açıklamaların tahmin modeline, açıklama yöntemine, açıklanan gözlem sayısına ve veri setlerinin sansürleme özelliklerine bağlı olarak nasıl değiştiği araştırılmaktadır.

**Makale durumu:** Bu depo, hazırlık aşamasındaki bilimsel makaleye eşlik etmektedir. Araştırmanın yeniden üretilebilirliğini desteklemek amacıyla analiz kodları ve mevcut sonuçlar paylaşılmaktadır.

---

## 1. Çalışmanın Genel Özellikleri

| Bileşen | Açıklama |
|---|---|
| Veri setleri | SurvSet koleksiyonundan 24 survival veri seti |
| Tahmin modelleri | 12 farklı survival modeli |
| Açıklama yöntemleri | SurvSHAP(t) ve SurvPFI |
| Veri ayrımı | %70 eğitim, %30 test |
| SurvSHAP gözlem sayıları | 15, 50 ve 100 |
| SurvPFI | Zamana bağlı Brier skoru, 10 permütasyon |
| Değişken önemi özeti | FI-AUC |
| Açıklama uyumu | Weighted Kendall's Tau, Top-3 Overlap ve Symmetric KL Divergence |
| Zamansal değişkenlik | Temporal Importance Volatility (TIV) ve Global Instability Score |

## 2. Araştırma Soruları

### RQ1 — Model Çeşitliliği

Veri seti ve açıklama yöntemi sabit tutulduğunda, farklı tahmin modelleri arasında global değişken önemi açıklamaları ne ölçüde değişmektedir?

### RQ2 — Açıklama Yöntemi Çeşitliliği

Aynı tahmin modeli ve veri seti üzerinde SurvSHAP ve SurvPFI yöntemleri ne ölçüde benzer açıklamalar üretmektedir?

### RQ3 — Sayısal Kararlılık

Global SurvSHAP açıklamalarında kullanılan gözlem sayısının (N = 15, 50 ve 100) değiştirilmesi, değişken önemi sıralamalarını ve açıklama profillerinin uyumunu nasıl etkilemektedir?

### RQ4 — Zamansal Değişkenlik

Değişken öneminin zaman içerisindeki değişkenliği, farklı tahmin modelleri ve açıklama yöntemleri arasında nasıl farklılaşmaktadır?

### RQ5 — Sansürleme ve Açıklama Uyumu

Veri seti düzeyindeki sansürleme oranı ile SurvSHAP ve SurvPFI açıklamaları arasındaki uyum arasında bir ilişki bulunmakta mıdır?

---

## 3. Yöntemler

Her veri seti %70 eğitim ve %30 test olarak ayrılmaktadır. Tahmin modelleri eğitim verileri üzerinde eğitilirken açıklama analizleri test verileri üzerinde gerçekleştirilmektedir.

### 3.1. SurvSHAP(t)

Bireysel gözlemler için hesaplanan zamana bağlı SHAP katkılarının mutlak değerlerini birleştirerek global değişken önemi eğrileri oluşturulmaktadır.

### 3.2. SurvPFI

Bir değişkenin değerleri rastgele karıştırıldığında zamana bağlı Brier skoru kaybındaki değişim ölçülerek değişkenin önemi değerlendirilmektedir.

### 3.3. FI-AUC

Zamana bağlı değişken önemi eğrileri, eğri altında kalan alan kullanılarak tek bir sayısal değere indirgenmektedir. Böylece değişkenlerin sıralanması ve açıklama yöntemlerinin karşılaştırılması kolaylaşmaktadır.

### 3.4. Açıklama Uyumu

Açıklamaların karşılaştırılmasında üç tamamlayıcı ölçüt kullanılmaktadır:

- **Weighted Kendall's Tau:** Değişken sıralamalarının uyumu.
- **Top-3 Overlap:** En önemli üç değişkenin örtüşmesi.
- **Symmetric KL Divergence:** Göreli değişken önemi dağılımlarının farklılığı.

### 3.5. Temporal Importance Volatility

Temporal Importance Volatility (TIV), bir değişkenin öneminin ardışık zaman noktaları arasında ne kadar değiştiğini ölçmektedir.

Model düzeyindeki ağırlıklı özet, **Global Instability Score** olarak tanımlanmaktadır:

$$
\overline{\mathrm{TIV}}_{\mathcal{M}}
=
\sum_{j=1}^{p}
\bar{R}_j \cdot \mathrm{TIV}(j)
$$

Burada $\bar{R}_j$, ilgili değişkenin göreli önem ağırlığını göstermektedir.

Daha düşük değerler, tanımlanan ölçüte göre daha düşük zamansal dalgalanmayı ifade etmektedir.

---

## 4. GitHub Depo Yapısı

```text
Survival-XAI/
├── R/                 # Veri hazırlama, modelleme, açıklama ve grafik kodları
├── datasets/          # Veri setleriyle ilgili dosyalar
├── results/           # Deney sonuçları ve CSV özetleri
├── renv/              # R paket ortamı
└── README.md          # Proje dokümantasyonu
```

Depoda temel analiz kodlarının yanı sıra önceki deneylere ait sonuçlar da bulunmaktadır.

Bazı ara CSV dosyaları ve grafik üretim bağımlılıkları depoda bulunmayabilir.

### Temel R Kodları

| Dosya | Görevi |
|---|---|
| `02_import_datasets.R` | Veri setlerinin yüklenmesi ve ön işleme |
| `03_modeling.R` | Tahmin modellerinin eğitilmesi |
| `04_performance.R` | Tahmin performansının değerlendirilmesi |
| `05_global_explain.R` | SurvPFI analizleri |
| `06_shap_analysis.R` | SurvSHAP(t) analizleri |
| `00_run_dataset.R` | Veri seti bazında analizlerin yürütülmesi |
| `07_agreement_metrics.R` | Açıklama uyum metriklerinin hesaplanması |

Diğer grafik ve araştırma sorusu analiz kodları `R/` klasörü altında yer almaktadır.

---

## 5. Analizlerin Yeniden Gerçekleştirilmesi

Analizlerin yeniden yapılabilmesi için temel iş akışı şöyledir:

1. Uygun R sürümü ve gerekli paketler kurulmalıdır.
2. İlgili survival veri setleri SurvSet koleksiyonundan edinilmelidir.
3. Veri yolları ve deneysel ayarlar kontrol edilmelidir.
4. Veri hazırlama ve modelleme kodları çalıştırılmalıdır.
5. SurvSHAP ve SurvPFI açıklamaları hesaplanmalıdır.
6. FI-AUC, uyum ölçütleri ve zamansal değişkenlik analizleri gerçekleştirilmelidir.
7. Mevcut sonuç dosyaları ve grafik kodları kullanılarak bulgular incelenebilir.

### Yeniden Üretilebilirlik Notu

Bazı deneyler önemli hesaplama kaynakları gerektirmektedir.

Eğitilmiş modeller ve büyük ara hesaplama dosyaları GitHub takibinin dışında tutulabilir. Ayrıca bazı grafik kodlarının ihtiyaç duyduğu ara CSV dosyaları henüz depoda bulunmayabilir.

Bu nedenle bütün analizlerin tek komutla yeniden üretilebildiği iddia edilmemektedir.

---

## 6. Veri Erişimi

Çalışmada kullanılan veri setleri, herkese açık [SurvSet](https://github.com/MLSurvival/SurvSet) koleksiyonundan elde edilmiştir.

Veri setlerinin kullanım koşulları ve ayrıntılı bilgileri için orijinal SurvSet belgelerine başvurulmalıdır.

---

## 7. Atıf

Bu çalışmadan yararlanılması durumunda, nihai yayın bilgileri açıklandıktan sonra ilgili makaleye atıf yapılması önerilmektedir.

**Makale:**

*An Empirical Evaluation of Feature Importance in Explainable Survival Modeling*

**Durum:** Hazırlık aşamasında.

---

## 8. İletişim

Çalışma, analiz kodları veya deneysel sonuçlarla ilgili sorular için GitHub Issues bölümü kullanılabilir.
