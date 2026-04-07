library(carData)
library(MASS)
library(marginaleffects)
library(modelsummary)
library(nnet)
library(pscl)
library(ggplot2)
library(AER)
library(survival)
library(survminer)

# ===================================================
# Part 1: Ordinal and Multinomial Outcomes (BEPS)
# ===================================================

data(BEPS)

# ----------------------------------------------------------
# 1. Ordered logit: perceptions of the national economy
# ----------------------------------------------------------

# a)
table(BEPS$economic.cond.national)
BEPS$econ_ord = factor(BEPS$economic.cond.national, ordered = TRUE)

# b)
m_ologit = polr(econ_ord ~ age + gender +
  Europe + political.knowledge,
  data = BEPS, Hess = TRUE)
summary(m_ologit)

# c)
avg_slopes(m_ologit)

# d)
predictions(m_ologit,
  newdata = datagrid(gender = c("female", "male")))

# ----------------------------------------------------------
# 2. Multinomial logit: vote choice
# ----------------------------------------------------------

# a)
BEPS$vote = relevel(BEPS$vote, ref = "Conservative")
m_mlogit = multinom(vote ~ economic.cond.national + Blair + Hague +
                           Kennedy + Europe, data = BEPS, trace = FALSE)
summary(m_mlogit)

# b)
avg_slopes(m_mlogit)

# c)
# IIA: odds ratio between any two alternatives unaffected by other alternatives.
# Labour and Lib Dem are both centre-left (moderate concern); Conservatives are
# clearly distinct. IIA plausible overall, but cautious for Labour/Lib Dem pair.

# ==========================================================================
# Part 2: Count Data (bioChemists) [In-class]
# ==========================================================================

data(bioChemists)

# ----------------------------------------------------------
# 3. Poisson regression: publication counts
# ----------------------------------------------------------

# a)
summary(bioChemists$art)
var(bioChemists$art)

ggplot(bioChemists, aes(x = art)) +
  geom_histogram(binwidth = 1, fill = "#294b66", color = "white") +
  theme_minimal() +
  labs(title = "Publications in last 3 years of PhD",
       x = "Number of articles", y = "Count")
ggsave("hist_art.pdf", width = 6, height = 4)

# b)
m_pois = glm(art ~ fem + mar + kid5 + phd + ment,
             data = bioChemists, family = poisson)
summary(m_pois)
exp(coef(m_pois)["ment"])

# c)
dispersiontest(m_pois)

# ----------------------------------------------------------
# 4. Negative binomial regression
# ----------------------------------------------------------

# a)
m_nb = glm.nb(art ~ fem + mar + kid5 + phd + ment,
              data = bioChemists)
summary(m_nb)

# b)
AIC(m_pois)
AIC(m_nb)

# c)
predictions(m_nb, newdata = datagrid(fem = c("Men", "Women")))

# d)
# Poisson inadequate (dispersion test p < 0.001, AIC ~3314 vs NB ~3136).
# NB ment IRR ~1.026: productive mentors modestly boost student output.
# Significant NB predictors: fem (negative), kid5 (negative), ment (positive).
# phd and mar not significant.
# Early-career productivity shaped by mentor environment, gender, and family demands.

# ==========================================================================
# Part 3: Survival Analysis (lung) [Take-home]
# ==========================================================================

lung = lung
lung$dead = lung$status - 1

# ----------------------------------------------------------
# 5. Kaplan-Meier survival curves
# ----------------------------------------------------------

# a)
nrow(lung)
sum(lung$dead == 1)
sum(lung$dead == 0)

# b)
km_all = survfit(Surv(time, dead) ~ 1, data = lung)
summary(km_all)
km_all

# c)
km_sex = survfit(Surv(time, dead) ~ sex, data = lung)
ggsurvplot(km_sex, data = lung, conf.int = TRUE,
  pval = TRUE, risk.table = TRUE,
  legend.labs = c("Male", "Female"))
ggsave("km_sex.pdf", width = 7, height = 5)

# ----------------------------------------------------------
# 6. Cox proportional hazards model
# ----------------------------------------------------------

# a)
cox_fit = coxph(Surv(time, dead) ~ age + sex + ph.ecog, data = lung)
summary(cox_fit)

# b)
exp(coef(cox_fit)["ph.ecog"])

# c)
cox.zph(cox_fit)

# d)
# KM shows clear separation by sex (log-rank p < 0.05): females survive longer.
# Cox model: sex (HR ~0.58, p < 0.01) and ph.ecog (HR ~1.59, p < 0.001) significant;
# age not significant. Females have ~42% lower hazard. Each unit increase in ECOG
# score (worse functioning) increases hazard by ~59%.
# PH assumption: check cox.zph() p-values. If all non-significant, assumption holds.
# Key finding: physical functioning is the strongest predictor of lung cancer survival.
