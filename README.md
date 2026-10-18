
# An Empirical Evaluation of Feature Importance in Explainable Survival Modeling

## 1. Overview

This repository contains the R code and computational results for an empirical study of global feature-importance explanations in survival analysis.

The study investigates how feature-importance explanations differ across predictive models, explanation methods, sample sizes used for global explanations, and time. It also examines the relationship between dataset censoring rates and agreement between explanation methods.

The experimental evaluation includes:

- **24 survival datasets** from the SurvSet collection.
- **12 survival prediction models** representing different modeling approaches.
- **Two explanation methods:** SurvSHAP and SurvPFI.
- **Three agreement measures:** Weighted Kendall's Tau, Top-3 Overlap, and Symmetric Kullback–Leibler Divergence.
- **Temporal analysis** of changes in feature importance over time.

Time-dependent feature-importance profiles are summarized using the area under the importance curve, allowing feature rankings and importance distributions to be compared across models and explanation methods.

### Research Questions

| Research Question | Focus |
|---|---|
| RQ1 | Agreement in feature importance across predictive models |
| RQ2 | Agreement between SurvSHAP and SurvPFI |
| RQ3 | Numerical stability of global SurvSHAP explanations |
| RQ4 | Temporal variability in feature importance |
| RQ5 | Relationship between censoring rate and explanation agreement |

---

## 2. Directory Structure

The repository contains the main computational scripts, datasets, and numerical results.

```text
Survival-XAI/
├── R/                  # Analysis and visualization scripts
├── datasets/           # Dataset-related files
├── results/            # Model performance and explanation results
├── project.Rproj       # RStudio project file
└── README.md           # Repository documentation
```

### Main R Scripts

| Script | Description |
|---|---|
| `00_run.R` | Main analysis workflow |
| `00_run_dataset.R` | Dataset-specific analysis |
| `01_install_packages.R` | Package installation |
| `02_import_datasets.R` | Data loading and preprocessing |
| `03_modeling.R` | Survival model training |
| `04_performance.R` | Predictive performance evaluation |
| `05_global_explain.R` | Permutation-based feature importance |
| `06_shap_analysis.R` | Time-dependent SHAP explanations |
| `07_agreement_metrics.R` | Comparison of feature-importance explanations |

Additional scripts in the `R/` directory support the analysis and visualization of individual research questions.

---

## 3. Computational Requirements

The analyses were implemented in R. The required packages can be installed using the provided installation script.

The computational workflow involves fitting survival prediction models and estimating time-dependent feature importance. Some analyses, particularly SurvSHAP calculations on larger datasets, may require substantial processing time.

---

## 4. Experimental Setup

### Datasets and Predictive Models

The study evaluates 12 survival prediction models on 24 datasets obtained from the SurvSet collection.

The datasets differ in sample size, number of features, follow-up duration, and censoring rate.

Each dataset is divided into training and test sets using a 70/30 split. Predictive models are fitted on the training data, while predictive performance and feature-importance explanations are evaluated on the held-out test data.

### Explanation Methods

**SurvSHAP** provides time-dependent feature contributions for individual observations. Global feature importance is obtained by aggregating the absolute contributions across the observations used for explanation.

**SurvPFI** evaluates feature importance by measuring changes in prediction loss after permuting the values of a feature. The time-dependent Brier score is used as the loss function in this study.

---

## 5. Feature Importance and Evaluation Measures

### 5.1. Area Under the Feature-Importance Curve

Feature-importance values can change over time in survival models. To obtain a single value for each feature, the area under its time-dependent importance curve is calculated.

These values are used to compare feature rankings and relative importance distributions across predictive models and explanation methods.

### 5.2. Agreement Between Explanations

Three complementary measures are used to assess agreement between global feature-importance explanations.

| Measure | Purpose |
|---|---|
| Weighted Kendall's Tau | Measures agreement between feature rankings, giving greater emphasis to highly ranked features |
| Top-3 Overlap | Measures the overlap among the three most important features |
| Symmetric Kullback–Leibler Divergence | Measures differences between relative feature-importance distributions |

Higher values of Weighted Kendall's Tau and Top-3 Overlap indicate stronger agreement. Lower values of Symmetric Kullback–Leibler Divergence indicate greater similarity between importance distributions.

### 5.3. Temporal Importance Volatility

Temporal Importance Volatility measures how much a feature's importance changes between consecutive evaluation times.

To summarize temporal variation for an entire model, feature-level volatility values are combined using their relative importance as weights. This model-level summary is referred to as the **Global Instability Score**.

Larger values indicate greater temporal fluctuations in the feature-importance profiles.

---

## 6. Replication Workflow


### Step 1: Obtain the Data

The survival datasets used in this study are available through the [SurvSet repository](https://github.com/ErikinBC/SurvSet).

### Step 2: Configure the R Environment

Install the required packages using the provided script:

```r
source("R/01_install_packages.R")
```

### Step 3: Run the Analysis

The computational workflow consists of four stages:

1. **Data preparation:** Import and preprocess the survival datasets.
2. **Modeling:** Fit survival models and evaluate predictive performance.
3. **Explanation:** Calculate time-dependent feature importance using SurvSHAP and SurvPFI.
4. **Evaluation:** Compare feature-importance explanations and examine their temporal variability.

The corresponding scripts are available in the `R/` directory.

### Step 4: Examine the Results

The `results/` directory contains the available numerical outputs, organized by predictive model and dataset.

These include predictive performance measures, SHAP feature-importance results, and permutation-based importance summaries.

---

## 7. Correspondence with the Manuscript

The empirical findings are presented in the manuscript through six figures.

| Analysis | Manuscript Figure |
|---|---|
| Dataset characteristics | Figure 1 |
| Agreement across predictive models | Figure 2 |
| Agreement between explanation methods | Figure 3 |
| Numerical stability of global SurvSHAP explanations | Figure 4 |
| Temporal variability in feature importance | Figure 5 |
| Censoring rate and explanation agreement | Figure 6 |

The analysis scripts and numerical results are organized in the `R/` and `results/` directories, respectively.
