options(stringsAsFactors = FALSE)

library(survival)
library(broom)
library(ggplot2)
library(marginaleffects)
data(lung)
lung$dead = lung$status - 1

# ==========================================================================
# 5. Kaplan-Meier survival curves
# ==========================================================================

# ----------------------------------------------------------
# a) Explore the data
# ----------------------------------------------------------

nrow(lung)
sum(lung$dead == 1)
sum(lung$dead == 0)

# 228 patients total. 165 deaths (events), 63 censored.
# Censoring proportion: ~27.6%. Moderate rate, typical for cancer studies.
# Censored patients' true survival times are unknown but >= observed times.
# Dropping or treating as events would bias estimates.

# ----------------------------------------------------------
# b) Overall Kaplan-Meier survival curve
# ----------------------------------------------------------

km_all = survfit(Surv(time, dead) ~ 1, data = lung)
summary(km_all)
km_all

# Median survival: 310 days (50% of patients survived beyond this point).
# The KM estimator handles censoring correctly: censored patients leave
# the risk set without counting as events.

# ----------------------------------------------------------
# c) Kaplan-Meier curves by sex
# ----------------------------------------------------------

km_sex = survfit(Surv(time, dead) ~ sex, data = lung)
km_df = tidy(km_sex)
ggplot(km_df, aes(x = time, y = estimate, color = strata, fill = strata)) +
  geom_step() +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, linetype = 0) +
  scale_color_manual(values = c("#294b66", "#f53831"),
    labels = c("Male", "Female")) +
  scale_fill_manual(values = c("#294b66", "#f53831"),
    labels = c("Male", "Female")) +
  labs(x = "Time (days)", y = "Survival probability", color = "", fill = "") +
  theme_minimal()
ggsave("km_sex.pdf", width = 7, height = 5)

# Log-rank test
survdiff(Surv(time, dead) ~ sex, data = lung)

# Females survive longer: female curve lies above male curve throughout.
# Confidence intervals show limited overlap in early/middle follow-up.
# Log-rank test p-value is significant: survival distributions differ
# between sexes. The log-rank test evaluates whether the two survival
# curves are identical -- rejection supports a sex-survival association.

# ==========================================================================
# 6. Cox proportional hazards model
# ==========================================================================

# ----------------------------------------------------------
# a) Fit Cox PH model and interpret sex hazard ratio
# ----------------------------------------------------------

cox_fit = coxph(Surv(time, dead) ~ age + sex + ph.ecog, data = lung)
summary(cox_fit)

# sex HR = 0.575: females have ~42% lower hazard of death than males.
# sex is coded 1 = male, 2 = female, so HR < 1 means female advantage.
# Effect is statistically significant (p < 0.01), consistent with KM analysis.

# ----------------------------------------------------------
# b) Interpret ph.ecog hazard ratio
# ----------------------------------------------------------

exp(coef(cox_fit)["ph.ecog"])

# ph.ecog HR = 1.59: each unit increase in ECOG score (worse functioning)
# is associated with ~59% higher hazard of death. Strongest predictor in
# the model. Highly significant (p < 0.001).

# ----------------------------------------------------------
# c) Test proportional hazards assumption
# ----------------------------------------------------------

cox.zph(cox_fit)

# None of the individual tests nor the global test are significant (all p > 0.05).
# The PH assumption is reasonable for all three covariates: the hazard ratios
# appear constant over time. If ph.ecog were significant, it would mean the
# effect of physical functioning changes over the course of the disease.

# ----------------------------------------------------------
# d) Summary
# ----------------------------------------------------------

# KM analysis shows clear, significant survival advantage for females (log-rank p < 0.05).
# Cox model confirms: sex HR = 0.58 (p < 0.01), ~42% lower hazard for females.
# ECOG performance score is the strongest predictor: HR = 1.59 (p < 0.001),
# each unit worsening in functioning increases hazard by ~59%.
# Age is not significant after controlling for sex and performance status.
# PH assumption holds (cox.zph global p > 0.05).
# Key finding: baseline physical functioning, not age, is the dominant predictor
# of lung cancer survival -- highlighting the clinical importance of performance
# status in prognosis.
