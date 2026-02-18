# setwd("~/Documents/AQM2")
options(stringsAsFactors = FALSE)

# ============================================================
# Assignment 3 -- Part 1: ANES Voter Turnout
# Applied Quantitative Methods II, UC3M
# ============================================================

# List of packages
library(dplyr)
library(broom)
library(ggplot2)
library(modelsummary)
library(marginaleffects)

# --------
## 1. Setup and data preparation

# a) Load and recode variables
raw = read.csv("https://raw.githubusercontent.com/franvillamil/AQM2/refs/heads/master/datasets/anes/anes_timeseries_2020.csv")

df = raw %>%
  transmute(
    voted = ifelse(V202109x < 0, NA, V202109x),
    age = ifelse(V201507x < 0, NA, V201507x),
    female = case_when(V201600 == 2 ~ 1, V201600 == 1 ~ 0, TRUE ~ NA_real_),
    education = case_when(
      V201511x == 1 ~ 10, V201511x == 2 ~ 12, V201511x == 3 ~ 14,
      V201511x == 4 ~ 16, V201511x == 5 ~ 20, TRUE ~ NA_real_),
    income = ifelse(V201617x < 0, NA, V201617x),
    party_id = ifelse(V201231x < 0, NA, V201231x)
  )

# b) Drop missing values
df = na.omit(df)
nrow(df)

# c) Turnout rate and summary statistics
mean(df$voted)
summary(df)

# --------
## 2. Exploratory visualization

# a) Bar chart of turnout by education level
turnout_by_edu = df %>%
  group_by(education) %>%
  summarise(turnout = mean(voted))

ggplot(turnout_by_edu, aes(x = factor(education), y = turnout)) +
  geom_col() +
  labs(x = "Years of education", y = "Turnout rate")

# b) Turnout increases monotonically with education.

# --------
## 3. Linear probability model

# a) Estimate LPM
lpm = lm(voted ~ age + education + income + female, data = df)

# b) Print results
tidy(lpm)

# c) The coefficient on education is the estimated change in the
# probability of voting for each additional year of education,
# holding other variables constant.

# d) Check predicted probabilities
preds_lpm = predict(lpm)
sum(preds_lpm < 0)
sum(preds_lpm > 1)
range(preds_lpm)

# --------
## 4. Logistic regression

# a) Estimate logit
logit = glm(voted ~ age + education + income + female,
            family = binomial, data = df)

# b) Print results
tidy(logit)

# c) Odds ratios
exp(coef(logit))
# The odds ratio for education indicates the multiplicative change in the odds
# of voting for each additional year of education.

# d) Verify predicted probabilities are bounded
preds_logit = predict(logit, type = "response")
range(preds_logit)

# --------
## 5. Comparing LPM and logit

# a) Average marginal effects
avg_slopes(logit)

# b) The AMEs from the logit are similar to the LPM coefficients.
# Both approaches tell a broadly similar story.

# c) Side-by-side table
modelsummary(list("LPM" = lpm, "Logit" = logit),
             vcov = list("robust", NULL))

# --------
## 6. Predicted probabilities

# a) Predicted probability across education
p1 = plot_predictions(logit, condition = "education")
ggsave("pred_prob_education.png", p1, width = 6, height = 4)

# b) Predicted probabilities by age and gender
p2 = plot_predictions(logit, condition = c("age", "female"))
ggsave("pred_prob_age_gender.png", p2, width = 6, height = 4)

# c) Education shows a clear positive relationship with turnout. Age also
# has a positive effect. The gender gap is modest relative to the age effect.

# --------
## 7. Presenting results

# a-b) Coefficient plot
p3 = modelplot(list("LPM" = lpm, "Logit" = logit),
               vcov = list("robust", NULL))
ggsave("coefplot_lpm_logit.png", p3, width = 6, height = 4)

# c) For this dataset, LPM and logit lead to similar substantive conclusions.
# Age, education, and income are all positively associated with turnout.
# The differences between the two approaches matter more when predicted
# probabilities are near 0 or 1. Here, turnout is relatively common, so the
# linear approximation works well.
