# Walmart Sales Forecasting (Purchase Prediction)

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Dataset](#-dataset)
- [Methodology](#-methodology)
- [Models Evaluated](#-models-evaluated)
- [Results](#-results)
- [Key Findings](#-key-findings)
- [Repository Structure](#-repository-structure)
- [How to Run](#-how-to-run)
- [Author](#-author)

---

## 🎯 Project Overview

This project focuses on predicting **customer purchase amounts** using the **Walmart Black Friday retail dataset**.  

**Objective:** Build and compare multiple regression-based machine learning models to estimate purchase behavior and identify the best-performing approach.

- **Problem Type:** Supervised Learning (Regression)  
- **Target Variable:** `Purchase` (purchase amount in dollars)
- **Evaluation Metrics:** RMSE, MAE, R-squared

---

## 📊 Dataset

**Source:** [Kaggle — Walmart e-Commerce Sales Dataset (Black Friday)](https://www.kaggle.com/datasets/devarajv88/walmart-sales-dataset)

**Description:** Retail transaction dataset containing customer demographics, product categories, and purchase amounts.

### Dataset Overview
- **Total Records:** 550,068 transactions
- **Unique Users:** 5,891 customers
- **Unique Products:** 3,631 products

### Key Features
| Feature | Description |
|---------|-------------|
| `User_ID` | Unique customer identifier |
| `Product_ID` | Unique product identifier |
| `Gender` | Customer gender (M/F) |
| `Age` | Customer age group |
| `Occupation` | Customer occupation (encoded) |
| `City_Category` | City type (A/B/C) |
| `Stay_In_Current_City_Years` | Years in current city |
| `Marital_Status` | Marital status (0/1) |
| `Product_Category_1/2/3` | Product categories |
| **`Purchase`** | **Target variable (purchase amount)** |

> **Note:** The raw dataset is not included in this repository due to size constraints.  
> Please download it from [Kaggle](https://www.kaggle.com/datasets/devarajv88/walmart-sales-dataset) and place it under `data/raw/`.

---

## 🔬 Methodology

### 1. Data Cleaning & Preprocessing
- Checked for missing values and duplicates (none found)
- Standardized column names to lowercase
- Converted categorical variables to factors
- Removed unnecessary identifiers (`User_ID`, `Product_ID`)

### 2. Exploratory Data Analysis (EDA)
- Analyzed purchase patterns by age, gender, occupation, and product category
- Identified right-skewed distribution in purchase amounts
- Visualized relationships between features and target variable

### 3. Outlier Detection
- Applied **IQR (Interquartile Range)** method
- Found **0.49% outliers** (2,677 out of 550,068 transactions)
- Outliers concentrated in premium product categories (9, 10, 15)

### 4. Feature Engineering
- Created numeric encodings for categorical variables
- Applied **log transformation** on `Purchase` to:
  - Reduce skewness and stabilize variance
  - Improve model performance (especially for linear models)
  - Mitigate impact of outliers

### 5. Model Training & Validation
- **Validation Strategy:**
  - 5-fold Cross-Validation for linear models
  - 70:30 Train-Test Split for complex models (due to computational constraints)
- **Hyperparameter Tuning:** Grid search for Ridge, Lasso, and tree-based models

---

## 🤖 Models Evaluated

The following models were trained and compared:

| Model | Type | Key Characteristics |
|-------|------|---------------------|
| **Linear Regression** | Baseline | Simple, interpretable |
| **Ridge Regression** | Regularized Linear | L2 penalty, handles multicollinearity |
| **Lasso Regression** | Regularized Linear | L1 penalty, feature selection |
| **Random Forest** | Ensemble (Bagging) | Non-linear, robust to outliers |
| **Gradient Boosting (GBM)** | Ensemble (Boosting) | Sequential error correction |
| **XGBoost** | Advanced Boosting | Not evaluated (similar to GBM, time constraints) |
| **Neural Network** | Deep Learning | Not completed (training time >5 hours) |

---

## 📈 Results

### Model Performance Comparison

| Model | RMSE | R² | MAE | Notes |
|-------|-----:|---:|----:|-------|
| **Linear Regression (Log)** ✅ | **0.3799** | **0.7359** | **0.2859** | **Best overall** |
| Lasso Regression (Log) | 0.3800 | 0.7358 | 0.2860 | Nearly identical to Linear |
| Ridge Regression (Log) | 0.3820 | 0.7344 | 0.2873 | Slightly lower performance |
| Linear Regression (Raw) | 3014.09 | 0.6399 | 2282.59 | Baseline (no transformation) |
| Ridge Regression (Raw) | 3027.54 | 0.6390 | 2287.48 | Baseline regularized |
| Lasso Regression (Raw) | 3014.17 | 0.6399 | 2282.70 | Baseline with feature selection |
| GBM (Raw) | 3241.94 | 0.5828 | 2454.09 | Non-linear approach |
| GBM (Log → Raw) | 3533.96 | 0.5060 | 2607.78 | Degraded after back-transform |
| Random Forest (Raw) | 3864.52 | 0.4000 | 2945.00 | High variance |
| Random Forest (Log → Raw) | 10531.06 | - | - | Amplified errors |

> **Note:** Log-transformed model metrics (RMSE, MAE) are on the log scale.  
> For fair comparison with raw models, predictions were back-transformed using `exp()` where applicable.

---

## 💡 Key Findings

### Best Model: Log-Transformed Linear Regression
- **Why it won:**
  - Lowest RMSE (0.3799) and MAE (0.2859)
  - Highest R² (0.7359) — explains ~74% of variance
  - Most interpretable and computationally efficient
  - Stable performance with 5-fold cross-validation

### 📊 Important Insights

1. **Log Transformation is Critical**
   - Dramatically improved linear model performance (R² from 0.64 → 0.74)
   - Stabilized variance and reduced heteroscedasticity
   - Mitigated impact of outliers

2. **Linear Relationships Dominate**
   - Simple linear models outperformed complex non-linear models
   - Suggests underlying linear relationship between features and purchase amount
   - Regularization (Ridge/Lasso) provided minimal improvement

3. **Complex Models Underperformed**
   - Random Forest and GBM showed lower R² despite higher complexity
   - Long training times without performance gains
   - Log transformation hurt tree-based models after back-transformation

4. **Feature Importance**
   - All predictors showed statistical significance (low p-values)
   - No multicollinearity issues (VIF < 5 for all features)
   - Age, occupation, and product category were key drivers

### Business Implications

**Customer Segmentation:** Identify high-value customers for targeted marketing  
**Demand Forecasting:** Predict purchase patterns by demographics  
**Inventory Management:** Optimize stock for high-demand product categories  
**Pricing Strategy:** Dynamic pricing based on predicted purchase behavior

---

## 📁 Repository Structure

```
walmart-sales-forecasting/
│
├── data/
│   ├── raw/                        # Raw dataset (download from Kaggle)
│   └── processed/                  # Cleaned and preprocessed data
│
├── notebooks/
│   ├── 01_EDA.Rmd                 # Exploratory Data Analysis
│   ├── 02_Feature_Engineering.Rmd # Feature engineering & transformation
│   ├── 03_Model_Training.Rmd      # Model training & hyperparameter tuning
│   └── 04_Model_Evaluation.Rmd    # Results & comparison
│
├── src/
│   ├── data_preprocessing.R       # Data cleaning functions
│   ├── feature_engineering.R      # Feature creation utilities
│   ├── model_training.R           # Model training pipeline
│   └── evaluation.R               # Evaluation metrics
│
├── models/                         # Saved model objects (.rds files)
├── results/                        # Performance metrics & visualizations
├── docs/                          # Documentation & reports
│
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt               # R package dependencies
```

---

## 🚀 How to Run

### Prerequisites
- **R** (>= 4.0.0)
- **RStudio** (recommended)

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/walmart-sales-forecasting.git
cd walmart-sales-forecasting
```

**2. Install required R packages**
```r
# Run in R console
install.packages(c(
  "tidyverse",      # Data manipulation & visualization
  "caret",          # Machine learning framework
  "glmnet",         # Ridge/Lasso regression
  "randomForest",   # Random Forest
  "gbm",            # Gradient Boosting
  "skimr",          # Data summary
  "MASS",           # Statistical tools
  "car"             # VIF calculation
))
```

**3. Download the dataset**
- Go to [Kaggle - Walmart Black Friday Dataset](https://www.kaggle.com/)
- Download the dataset
- Place it in `data/raw/` directory

**4. Run the analysis**
```r
# Option 1: Run notebooks sequentially in RStudio
# Open notebooks/01_EDA.Rmd → 02_Feature_Engineering.Rmd → ...

# Option 2: Run scripts programmatically
source("src/data_preprocessing.R")
source("src/feature_engineering.R")
source("src/model_training.R")
source("src/evaluation.R")
```

---

## 📚 Documentation

For detailed analysis and methodology, see:
- **Full Report:** [`docs/Walmart_Sales_Forecasting_Report.pdf`](docs/)
- **Code Documentation:** Comments in `src/` and `notebooks/`

---

## ⚠️ Limitations & Future Work

### Current Limitations
- No temporal data (timestamps unavailable)
- Computational constraints prevented full Neural Network training
- Some models used manual splits instead of cross-validation

### Future Improvements
- Incorporate time-series features if temporal data becomes available
- Deploy model as REST API for real-time predictions
- Experiment with ensemble methods combining top models
- A/B testing for business impact validation

---


## 👤 Author

**Minwoo Park**  
📧 University of Georgia | MIST 5635  
💼 [LinkedIn](https://www.linkedin.com/in/mp74484/)  

---

## 🙏 Acknowledgments

- Dataset: [Kaggle - Walmart Black Friday Sales](https://www.kaggle.com/datasets/devarajv88/walmart-sales-dataset )
- Tools: R, RStudio, tidyverse ecosystem

---
