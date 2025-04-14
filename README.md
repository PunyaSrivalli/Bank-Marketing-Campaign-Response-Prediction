# Predicting Bank Subscription Response using Random Forest

## Overview
This project focuses on predicting customer subscription responses to a term deposit marketing campaign, using a real-world bank dataset. We cleaned and explored the data through detailed EDA and built a Random Forest model that achieves high precision and recall, helping to identify likely subscribers for future campaigns.

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
- Understand the key factors influencing a customer’s likelihood to subscribe to a term deposit.
- Clean and preprocess marketing campaign data for modeling.
- Build an effective classification model to identify potential subscribers.

---

## Dataset
- **Source**: [UCI Bank Marketing Dataset](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing)
- **Scope**: Direct marketing campaigns of a Portuguese banking institution.
- **Size**: Originally 45,000+ rows; filtered down to 40,841 after cleaning.
- **Target**: `response` — whether the client subscribed to a term deposit.

---

## Key Methodologies

### Exploratory Data Analysis (EDA)
We performed targeted EDA to uncover insights:
- Removed outliers in the `balance` field (Z-score method).
- Transformed `duration` to minutes.
- Encoded `month` as an integer for chronological analysis.
- Created visualizations:
  - **Distributions** of age and balance.
  - **Scatter plots**: call duration vs number of calls.
  - **Bar charts**: subscription percentage by age, job, and balance groups.
- Key Insights:
  - Subscriptions were more frequent with **shorter, fewer calls**.
  - **Younger and older age groups** responded better.
  - Clients with **no balance** or **low balance** were less likely to subscribe.

### Feature Engineering
We performed one-hot encoding for categorical fields including:
- Job
- Marital status
- Education level
- Default, housing, and loan status
- Month

Additionally:
- Removed rows with over 50% "unknown" values.
- Dropped uninformative or redundant columns (e.g., `poutcome`).

### Modeling
We used a **Random Forest Classifier** with the following settings:
- Trees (`ntree`) = 500
- Train-test split: 60% training, 40% testing
- Classification threshold: 0.5

---

## Classification Strategy
We modeled the problem as **binary classification**:
- **1**: Subscribed to the term deposit
- **0**: Did not subscribe

Evaluation Metrics:

| Metric              | Value     |
|---------------------|-----------|
| Accuracy            | 91.48%    |
| Precision (Class 1) | 94.39%    |
| Recall (Class 1)    | 96.08%    |
| F1-Score (Class 1)  | 95.23%    |
| % Variance Explained (RF) | 41.63% |

Confusion Matrix:

|               | **Actual: 0** | **Actual: 1** |
|---------------|---------------|---------------|
| **Predicted: 0** | 13,893       | 825           |
| **Predicted: 1** | 566          | 1,052         |

---

## Results
- The **Random Forest model** performed very well in identifying subscribers.
- Achieved high precision and recall on the minority class (`Subscribed = 1`).
- The model explained **41.63%** of the variance in response behavior.
- Weighted F1-score: **95.23%**

---

## Future Scope
- Explore **SMOTE or resampling techniques** for class imbalance.
- Test other ensemble models like **XGBoost** or **LightGBM**.
- Add customer **contact history or behavioral data** for better prediction.
- Integrate **real-time dashboard** for campaign managers to identify leads.

---

## Tools & Libraries
- **Language**: R
- **Libraries**: `data.table`, `ggplot2`, `dplyr`, `psych`, `randomForest`, `caret`
- **Editor**: RStudio
