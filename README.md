
# An Empirical Evaluation of Feature Importance in Explainable Survival Modeling

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

The repository is organized around the main analysis scripts and their computational outputs.

```text
Survival-XAI/
├── R/                  # Analysis and visualization scripts
├── datasets/           # Dataset-related files
├── results/            # Model and explanation results
├── project.Rproj       # RStudio project file
└── README.md           # Project documentation
```

### Main R Scripts

| Script | Description |
|---|---|
| `00_run.R` | Main workflow orchestration |
| `00_run_dataset.R` | Dataset-specific execution |
| `01_install_packages.R` | Installation of required R packages |
| `02_import_datasets.R` | Data loading and preprocessing |
| `03_modeling.R` | Survival model training |
| `04_performance.R` | Predictive performance evaluation |
| `05_global_explain.R` | SurvPFI computation |
| `06_shap_analysis.R` | Time-dependent SurvSHAP computation |
| `07_agreement_metrics.R` | Explanation agreement analysis |
| `plots.R` | Visualization of research-question-specific results |

---

## 3. Computational Requirements

The analyses are implemented in R. Required packages can be installed using the provided installation script:

```r
source("R/01_install_packages.R")
```

The workflow involves survival model training, time-dependent feature-importance estimation, and comparison of global explanations.

SurvSHAP computations may require substantial computational resources, particularly for large datasets and larger explanation sample sizes.

---

## 4. Experimental Setup

### Datasets and Predictive Models

The empirical evaluation covers **24 survival datasets** from the SurvSet repository and **12 predictive survival models**.

The datasets differ in sample size, feature dimensionality, follow-up duration, and censoring rate.

Each dataset is partitioned into training (70%) and test (30%) subsets. Predictive models are fitted using the training data, while predictive performance and explanations are evaluated on held-out test observations.

### Explanation Methods

**SurvSHAP(t)** produces time-dependent SHAP attributions for survival models. Global feature importance is obtained by aggregating the absolute local contributions across explained observations.

**SurvPFI** measures feature importance through changes in predictive loss following feature permutation. In this study, the time-dependent Brier score is used for performance-based importance estimation.

---

## 5. Feature Importance and Evaluation Measures

### 5.1. Feature-Importance Area Under the Curve (FI-AUC)

Time-dependent feature-importance trajectories are summarized by integrating their positive contributions over the observation period.

This scalar representation supports feature ranking and comparisons across predictive models and explanation methods.

### 5.2. Agreement Between Explanations

Three complementary measures are employed:

| Measure | Purpose |
|---|---|
| Weighted Kendall's Tau | Agreement between feature rankings, emphasizing highly ranked features |
| Top-3 Overlap | Overlap among the three most influential features |
| Symmetric KL Divergence | Differences between relative feature-importance distributions |

Higher values of Weighted Kendall's Tau and Top-3 Overlap indicate stronger agreement, whereas lower Symmetric KL Divergence indicates more similar importance distributions.

### 5.3. Temporal Importance Volatility (TIV)

Temporal Importance Volatility (TIV) quantifies fluctuations in feature importance between consecutive evaluation times.


At the model level, these feature-level values are combined into a weighted summary, referred to as the **Global Instability Score**:

```math
\overline{\mathrm{TIV}}_{\mathcal{M}} =
\sum_{j=1}^{p} \bar{R}_j \cdot \mathrm{TIV}(j)
```

where $\bar{R}_j$ denotes the relative importance weight of feature $j$.

Larger values indicate greater temporal variability in the feature-importance profiles.


---

## 6. Replication Workflow

### Step 1: Obtain the Data

The survival datasets are publicly available through the [SurvSet repository](https://github.com/MLSurvival/SurvSet).

### Step 2: Configure the R Environment

Install the required packages using:

```r
source("R/01_install_packages.R")
```

### Step 3: Run the Analysis

The computational workflow consists of four main stages:

1. **Data preparation:** Import datasets and create training/test partitions.
2. **Modeling:** Fit survival models and evaluate predictive performance.
3. **Explanation:** Compute SurvSHAP and SurvPFI explanations.
4. **Evaluation:** Calculate FI-AUC, explanation agreement measures, temporal variability, and visualizations.

The corresponding scripts are provided in the `R/` directory.

### Step 4: Examine the Results

Computational results are stored in the `results/` directory.

Available outputs include predictive performance summaries, SHAP feature-importance profiles, and permutation-based importance summaries.

---

## 7. Verification and Correspondence with the Manuscript

The empirical results are organized according to the research questions addressed in the manuscript.

| Research Question | Manuscript Figure |
|---|---|
| Dataset characteristics | Figure 1 |
| RQ1 — Model multiplicity | Figure 2 |
| RQ2 — Explanation method agreement | Figure 3 |
| RQ3 — Numerical stability | Figure 4 |
| RQ4 — Temporal variability | Figure 5 |
| RQ5 — Censoring and explanation agreement | Figure 6 |

The corresponding analysis scripts are available in `R/`, and numerical outputs are provided in `results/`.
