# 🧠 Client Profile System for Behavioral Healthcare Service

### Yingchen (Lana) Zhang | Neuropath Healthcare Solutions

---

## 📅 1. Introduction

Efficient service allocation in community behavioral health programs is often hindered by resource constraints and client heterogeneity. To move beyond reactive scheduling and anecdotal prioritization, we developed a **Client Profile System** — a statistical modeling framework and ShinyApp dashboard that identifies clients at highest risk for dropout or non-engagement.

Built on 12 behavioral and logistical dimensions, the system generates individual-level priority scores and recommends personalized outreach strategies, aiming to improve equity and efficiency in public mental health service delivery.

---

## 📈 2. Data & Feature Engineering

### 2.1 Data Cleaning and Imputation

* **Data Source**: Agency CRM system (Jan 1 – Jul 30, 2025) → 100 synthetic client profiles
* **Duplicates**: Removed via `dplyr::distinct()`
* **Ordinal scoring**: Most variables encoded on (0, 2, 4) scale to reflect non-linear risk gradients
* **Inverse scoring**: Used for Contact Frequency, Scheduling Flexibility, etc.
* **Missing data**: Imputed using `mice::mice()` with `method = "pmm"` (predictive mean matching) and `m = 5` iterations

e.g.,
| Client ID | Missing Variable        | Imputed Value |
| --------- | ----------------------- | ------------- |
| 13        | Transportation\_Barrier | 4 (Severe)    |
| 32        | Interest\_Level         | 4 (High)      |
| 84        | Digital\_Access         | 4 (None)      |

### 2.2 Behavioral Dimensions (12)

Derived from structured CRM system + real clients' intake forms. Examples:

* **Language\_Barrier** (Flores, 2006): Higher = worse communication
* **Interest\_Level** (Prochaska, 1982): Readiness for engagement
* **Contact\_Frequency** (Hoagwood, 2001): Inverse predictor of motivation

### 2.3 Feature Table (Excerpt)

e.g.,
| Variable                | Source       | Scoring Logic                 |
| ----------------------- | ------------ | ----------------------------- |
| Language\_Barrier       | CRM Tags     | None = 0, Mod = 2, Severe = 4 |
| Scheduling\_Flexibility | Intake Sheet | High = 0, Low = 4             |
| Referral\_Source        | CRM Notes    | School = 0, Other = 4         |

---

## 🔢 3. Modeling & Scoring System

### 3.1 Logistic Regression (AIC-based selection)

* **Outcome**: 0 = Enrolled in 30 days, 1 = Not enrolled
* Final retained variables: 7
* Model fit (AIC = 101.8), Null deviance = 136.4 → Residual = 85.8

e.g.,
| Predictor                 | Odds Ratio |
| ------------------------- | ---------- |
| Language\_Barrier\_Score  | 0.5444     |
| Interest\_Level\_Score    | 0.5524     |
| Contact\_Frequency\_Score | 0.5032     |

### 3.2 Random Forest (n=500 trees)

* Used `randomForest()` in R, `importance(type = 1)` for Gini impurity
* Top contributors by both metrics include:
 * Language_Barrier_Score (Gini: 6.47; Accuracy Drop: 7.56)
 * Interest_Level_Score (Gini: 4.36)
 * Transportation_Barrier_Score (Gini: 4.57)
 * Contact_Frequency_Score (Gini: 4.24)

### 3.3 Weighted Composite Score

* Combined normalized odds ratios + Gini importance using Z-score scaling
* Final scoring formula:

```r
score <- scale(logistic_ORs) * 0.6 + scale(Gini_importance) * 0.4
```

e.g.,
| Variable                  | Final Weight |
| ------------------------- | ------------ |
| Contact\_Frequency\_Score | 0.2112       |
| Responsiveness\_Score     | 0.1900       |

---

## 🔬 4. Validation & Results

### 4.1 Cross-Validation

* `cv.glm()` from `boot` package
* 10-fold cross-validation: **Error = 0.1787**, Bias-corrected = 0.1783

### 4.2 A/B Testing

* Clients grouped by **Total\_Score tertiles**
* Enrollment rate significantly varied by group (Chi-sq p = 2.33e⁻⁶)

| Priority Group | Enrolled | Not Enrolled |
| -------------- | -------- | ------------ |
| High           | 24       | 2            |
| Medium         | 19       | 19           |
| Low            | 3        | 32           |

---

## 🔍 5. Deployment: ShinyApp

### Tech Stack:

* `shiny`, `fmsb`, `dplyr`, `randomForest`, `broom`, `mice`
* Outputs: Radar Chart, Priority Text, Strategy Text, Score Guide Sidebar

### UI Features:

* **Dropdown menu** to select clients
* **Radar chart** per client on 7 selected dimensions
* **Priority band** based on 1SD above mean = High
* **Text card** showing tailored strategy
* **Sidebar guide** explaining each score (0-100 scale)

```r
selectInput("client_id", "Select a Client", choices = unique(client_data$Client_ID))
plotOutput("radarPlot")
verbatimTextOutput("priorityText")
```

Example Strategy Text:

> 🟡 Medium Priority: Follow-up within 3 days. Monitor responsiveness and engagement history.

---

## 📊 6. Summary & Impact

* ✅ Average outreach attempts reduced from **6.77 → 4.45**
* ✅ Follow-up efficiency improved by **\~34%**
* ✅ Stakeholder tool ready for real-world behavioral health agencies
* ✅ Framework extensible to other health or social services (e.g., housing, autism referrals)

---

## 🔗 References

1. White et al. (2011). *Statistics in Medicine*.
2. Harrell (2015). *Regression Modeling Strategies*. Springer.
3. Flores (2006). *New England Journal of Medicine*.
4. Antonelli et al. (2010). *Children’s Hospital Boston*.
5. van Buuren & Groothuis-Oudshoorn (2011). *J. Stat. Softw.*
6. Prochaska & DiClemente (1982). *Journal of Consulting and Clinical Psychology*.
7. Hoagwood et al. (2001). *Administration and Policy in Mental Health*.

---

## 📍 Appendix

### Screenshot: ShinyApp Radar Map View


* Client profile radar map
* Auto-prioritization
* Recommendation logic shown based on underlying composite score

---

## 👩‍⚕️ Author

**Lana (Yingchen) Zhang**  
M.S. in Biostatistics and Data Science @ Cornell University  
Behavioral Health Research Intern @ Neuropath Healthcare Solutions  
GCP Certified | R • SAS • SQL • Python  
[LinkedIn](https://www.linkedin.com/in/lana-zhang-891430327/) |lanazhangny023@gmail.com

Report Date: **August 15, 2025**
