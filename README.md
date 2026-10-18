
# Survival-XAI

## Replication Materials for Explainable Survival Modeling

**Study:** An Empirical Evaluation of Feature Importance in Explainable Survival Modeling

**Authors:** Yigitcan Yardimci and Mustafa Cavus

---

## 1. Overview

This repository provides the R implementation and computational results supporting an empirical evaluation of global feature-importance explanations in survival analysis.

The study examines how explanations vary across predictive models, explanation methods, numerical settings, temporal horizons, and dataset censoring characteristics.

The experimental framework includes:

- **24 survival datasets** from the SurvSet collection.
- **12 predictive survival models** representing different modeling approaches.
- **2 explanation methods:** SurvSHAP(t) and SurvPFI.
- **3 explanation agreement measures:** Weighted Kendall's Tau, Top-3 Overlap, and Symmetric KL Divergence.
- **Temporal feature-importance analysis** using Temporal Importance Volatility (TIV).

Time-dependent feature-importance profiles are summarized using an area-under-the-curve approach (FI-AUC), enabling comparisons of feature rankings and relative importance distributions.

### Research Questions

| RQ | Research Focus |
|---|---|
| RQ1 | Variation in feature-importance explanations across predictive models |
| RQ2 | Agreement between SurvSHAP and SurvPFI |
| RQ3 | Numerical stability of global SurvSHAP explanations |
| RQ4 | Temporal variability in feature importance across models and explanation methods |
| RQ5 | Association between dataset censoring rate and explanation agreement |

---

## 2. Directory Structure

The repository is organized around the main computational pipeline and its output files.

```text
Survival-XAI/
├── R/
│   ├── 00_run.R
│   ├── 00_run_dataset.R
│   ├── 01_install_packages.R
│   ├── 02_import_datasets.R
│   ├── 03_modeling.R
│   ├── 04_performance.R
│   ├── 05_global_explain.R
│   ├── 06_shap_analysis.R
│   ├── 07_agreement_metrics.R
│   └── [additional analysis and plotting scripts]
│
├── datasets/
│   └── [dataset-related files]
│
├── results/
│   └── [model-specific and dataset-specific outputs]
│
├── project.Rproj
└── README.md
```

### Main R Scripts

| Script | Description |
|---|---|
| `00_run.R` | Main workflow orchestration |
| `00_run_dataset.R` | Dataset-specific execution |
| `01_install_packages.R` | R package installation |
| `02_import_datasets.R` | Data loading and preprocessing |
| `03_modeling.R` | Survival model training |
| `04_performance.R` | Predictive performance evaluation |
| `05_global_explain.R` | Survival permutation feature-importance computation |
| `06_shap_analysis.R` | Time-dependent survival SHAP computation |
| `07_agreement_metrics.R` | Feature-importance agreement measures |

Additional scripts in `R/` support research-question-specific analyses and figure generation.

---

## 3. Computational Requirements and Dependencies

### Software

- R statistical computing environment
- R packages required by the analysis scripts
- A system capable of fitting the selected survival models

### Computational Considerations

The complete experimental workflow includes survival model fitting, permutation-based feature importance, and time-dependent SHAP explanations.

Execution time and memory requirements depend on dataset size, model complexity, and the number of observations used for explanation.

The SurvSHAP analyses can be computationally intensive, particularly for larger datasets and explanation sample sizes.

Users should inspect the package requirements and computational settings in the provided scripts before executing the complete workflow.

---

## 4. Experimental Setup

### Datasets

The empirical evaluation uses 24 survival datasets obtained from the SurvSet repository.

These datasets differ in sample size, feature dimensionality, follow-up duration, and censoring rate.

### Predictive Models

Twelve survival prediction models are evaluated:

1. Cox proportional hazards (Cox)
2. Accelerated Oblique Random Survival Forest (AORSF)
3. Conditional Random Forest (CForest)
4. CoxBoost
5. Conditional Inference Tree (CTree)
6. Cross-validated GLMNet (CV-GLMNet)
7. GLMBoost
8. GLMNet
9. Penalized Cox
10. Ranger
11. Random Survival Forest (RSF)
12. XGBoost Cox

### Training and Test Data

Each dataset is partitioned into:

- **70% training observations**
- **30% test observations**

Models are fitted using training data, while predictive performance and post-hoc explanations are evaluated on held-out test data.

### Explanation Methods

**SurvSHAP(t)** provides time-dependent feature attributions. Global feature importance is obtained by aggregating the absolute local SHAP contributions across explained observations.

**SurvPFI** quantifies the importance of a feature through the change in predictive loss after permuting that feature. In this study, time-dependent permutation importance is evaluated using the Brier score.

### Explanation Settings

| Parameter | Setting |
|---|---|
| Train/test split | 70% / 30% |
| Global SurvSHAP explanation sizes | 15, 50, 100 observations |
| SurvSHAP reference data | Held-out test dataset |
| SurvPFI loss | Time-dependent Brier score |
| SurvPFI permutation repetitions | 10 |
| Temporal evaluation | Dataset-specific test follow-up times |
| Agreement measures | Weighted Kendall's Tau, Top-3 Overlap, Symmetric KL Divergence |

---

## 5. Feature Importance and Evaluation Measures

### 5.1. Area Under the Feature-Importance Curve (FI-AUC)

Time-dependent feature-importance trajectories are converted into scalar summaries by integrating their positive contributions over the observation period.

This representation supports feature ranking and comparison across models and explanation methods.

### 5.2. Agreement Between Explanations

Three complementary measures are used:

| Measure | Evaluation |
|---|---|
| Weighted Kendall's Tau | Agreement in feature rankings, emphasizing highly ranked variables |
| Top-3 Overlap | Agreement among the three most important features |
| Symmetric KL Divergence | Differences in relative feature-importance distributions |

Higher Weighted Kendall's Tau and Top-3 Overlap indicate stronger agreement, whereas lower Symmetric KL Divergence indicates more similar importance distributions.

### 5.3. Temporal Importance Volatility

Temporal Importance Volatility (TIV) measures changes in feature importance between consecutive evaluation times.

At the model level, the weighted summary is defined as the **Global Instability Score**:

$$
\overline{\mathrm{TIV}}_{\mathcal{M}}
=
\sum_{j=1}^{p}
\bar{R}_j \cdot \mathrm{TIV}(j)
$$

where $\bar{R}_j$ represents the relative importance weight of feature $j$.

Larger values indicate greater temporal fluctuations in the feature-importance profiles.

---

## 6. Replication Workflow

### Step 1: Obtain the Data

The survival datasets are available through the SurvSet collection:

https://github.com/MLSurvival/SurvSet

### Step 2: Configure the R Environment

Install the R packages required by the provided scripts.

The project includes an installation script:

```r
source("R/01_install_packages.R")
```

Package availability and version compatibility should be checked before execution.

### Step 3: Review the Main Pipeline

The principal computational stages are:

1. Dataset import and preprocessing.
2. Survival model training.
3. Predictive performance evaluation.
4. SurvPFI computation.
5. SurvSHAP computation.
6. Feature-importance aggregation and agreement analysis.
7. Research-question-specific statistical analyses and visualizations.

The main workflow scripts are located in the `R/` directory.

Dataset-specific execution settings and output paths should be checked before running the full pipeline.

### Step 4: Examine Existing Results

Numerical results are organized in the `results/` directory by predictive model and dataset.

The available output files include predictive performance summaries, SHAP importance profiles, and permutation-importance summaries.

Large serialized R objects, including fitted models and explainer objects, are not required for inspecting the available CSV summaries.

---

## 7. Verification and Correspondence with the Manuscript

The manuscript organizes its empirical findings around five research questions.

| Research Question | Manuscript Analysis |
|---|---|
| RQ1 | Figure 2 — Model-to-model explanation similarity |
| RQ2 | Figure 3 — SurvSHAP and SurvPFI agreement |
| RQ3 | Figure 4 — Numerical stability across explanation sample sizes |
| RQ4 | Figure 5 — Temporal feature-importance variability |
| RQ5 | Figure 6 — Censoring rate and explanation agreement |

**Figure 1** summarizes the characteristics of the survival datasets.

Research-question-specific scripts and numerical summaries should be used together with the corresponding manuscript sections when interpreting the findings.

Not all intermediate objects or figure-generation inputs are necessarily included in the repository. Recreating an analysis may require regeneration of intermediate results.

---

## 8. Data Availability

The datasets used in this study are publicly available through the SurvSet repository:

**SurvSet:** https://github.com/MLSurvival/SurvSet

Users should consult the original dataset documentation and associated references for dataset-specific information.

---

## 9. Citation

If you use the code or results provided in this repository, please cite the associated study:

**Yardimci, Y., and Cavus, M.**

*An Empirical Evaluation of Feature Importance in Explainable Survival Modeling.*

Formal publication information and a complete bibliographic reference can be added when available.

---

## 10. Contact

For questions concerning the computational framework, analysis scripts, or study results, please use the GitHub Issues section.
