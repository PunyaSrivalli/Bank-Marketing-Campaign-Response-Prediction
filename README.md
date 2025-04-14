# Predicting Bank Subscription Response using Random Forest

## Overview
This project focuses on predicting customer subscription responses to a term deposit marketing campaign using real-world bank telemarketing data. Through data cleaning, exploratory analysis, and feature engineering, we trained a Random Forest classifier to identify potential subscribers and assist in optimizing future campaign strategies.

---

## Table of Contents
1. [Objectives](#objectives)
2. [Dataset](#dataset)
3. [Key Methodologies](#key-methodologies)
    - [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
    - [Feature Engineering](#feature-engineering)
    - [Modeling](#modeling)
4. [Classification Strategy](#classification-strategy)
5. [Results](#results)
6. [Future Scope](#future-scope)
7. [Tools & Libraries](#tools--libraries)

---

## Objectives
- Predict whether a customer will subscribe to a term deposit.
- Identify customer segments more likely to respond positively.
- Extract actionable insights for future marketing campaigns.

---

## Dataset
- **Source**: [Kaggle - Portuguese Bank Marketing Dataset](https://www.kaggle.com/datasets/yufengsui/portuguese-bank-marketing-data-set/data)
- **Period**: May 2008 – November 2010
- **Size**: ~47,000 records, 17 variables
- **Target**: `response_binary` (1 = subscribed, 0 = not subscribed)

---

## Key Methodologies

### Exploratory Data Analysis (EDA)
- **Age Trends**:
  - Majority of customers were in their 30s and 40s.
  - Subscription rate peaked at **53% for customers aged 60+**.
  - Age group <30 had the second highest subscription rate (32%).

- **Balance Distribution**:
  - Wide balance range from -6847 to 10443 euros.
  - Customers with **balances > 5000** had a **36% positive response rate**.
  - Customers with **negative balances** had only **21% response rate**.

- **Call Activity**:
  - Fewer, longer calls were more effective.
  - Most ‘yes’ responses occurred when customers were contacted **less than 5 times**.

- **Seasonality**:
  - March had the **highest subscription rate (~50%)**, despite low contact volume.
  - Most contacts occurred between May and August.

### Feature Engineering
- Dropped rows where `poutcome = unknown`
- Removed outliers in `balance` using Z-score threshold
- One-hot encoded categorical variables (job, education, marital, etc.)
- Dropped the `duration` variable (leakage risk)
- Converted month names to integer values for modeling

### Modeling
- **Algorithm**: Random Forest Classifier
- **Parameters**:
  - Trees: 500 (`ntree = 500`)
  - Train-test split: 60% training, 40% testing
- **Preprocessing**: Handled class imbalance via stratified sampling
- **Evaluation**: Confusion matrix, precision, recall, F1-score

---

## Classification Strategy
Binary classification problem:
- `1`: Subscribed to term deposit
- `0`: Did not subscribe

### Confusion Matrix

|               | **Actual: 0** | **Actual: 1** |
|---------------|---------------|---------------|
| **Predicted: 0** | 13,893       | 825           |
| **Predicted: 1** | 566          | 1,052         |

---

## Results

| Metric              | Value     |
|---------------------|-----------|
| Accuracy            | **91.48%** |
| Precision           | **94.39%** |
| Recall              | **96.08%** |
| F1-score            | **95.23%** |
| % Variance Explained (RF) | **41.63%** |

- Successfully captured high-value target segments.
- Demonstrated excellent recall for subscribed customers (critical for marketing use cases).

---

## Future Scope
- Apply **SMOTE** or oversampling for rare positive responses.
- Integrate **XGBoost** or **LightGBM** for boosted ensemble learning.
- Develop real-time deployment using **R Shiny** or **Flask API**.
- Track success rates across time using **seasonality-based dashboards**.

---

## Tools & Libraries
- **Language**: R
- **Libraries**: `data.table`, `ggplot2`, `dplyr`, `caret`, `randomForest`, `psych`
- **Environment**: RStudio

---

## Highlights for Business
- **Target Segments**:
  - Clients aged **<30** or **60+**
  - **Students** or **retired individuals**
  - Customers with **high balance accounts**
  - Focus on **March, September, October, December** for campaigns

---

