options(stringsAsFactors = FALSE)

library(carData)
library(MASS)
library(nnet)
library(pscl)
library(AER)
library(marginaleffects)
library(ggplot2)
data(BEPS)

# ==========================================================================
# 1. Ordered logit: perceptions of the national economy
# ==========================================================================

# ----------------------------------------------------------
# a) Explore outcome and convert to ordered factor
# ----------------------------------------------------------

table(BEPS$economic.cond.national)
BEPS$econ_ord = factor(BEPS$economic.cond.national, ordered = TRUE)

# Distribution concentrated in middle categories (2, 3, 4); category 3 is modal.
# OLS treats categories as equally spaced, which is implausible for Likert items:
# the perceived distance between "got much worse" (1) and "got a little worse" (2)
# need not equal the distance between "stayed the same" (3) and "got a little better" (4).
# Ordered logit estimates threshold parameters that let the data determine spacing.

# ----------------------------------------------------------
# b) Fit ordered logit model
# ----------------------------------------------------------

m_ologit = polr(econ_ord ~ age + gender + Europe + political.knowledge,
                data = BEPS, Hess = TRUE)
summary(m_ologit)

# NOTE: polr() reverses the sign convention. A positive raw coefficient means
# a NEGATIVE association with higher ordinal categories.
# The raw coefficient on Europe is negative, implying (after sign reversal) a
# positive association: more pro-EU respondents tend to perceive the economy
# as having improved. Plausible: Blair's pro-European government may be viewed
# more favorably by EU supporters. Use AMEs for magnitude interpretation.

# ----------------------------------------------------------
# c) Average marginal effects across all response categories
# ----------------------------------------------------------

avg_slopes(m_ologit)

# AMEs for Europe: negative on lower categories (1, 2), positive on higher (4, 5).
# One-unit increase in pro-EU attitude raises the probability of optimistic
# economic assessment and lowers the probability of pessimistic assessment.
# Sanity check: AMEs across all five categories sum to zero for each predictor.

# ----------------------------------------------------------
# d) Predicted probabilities by gender at covariate means
# ----------------------------------------------------------

predictions(m_ologit, newdata = datagrid(gender = c("female", "male")))

# Predicted probabilities for the extreme categories (1 = much worse, 5 = much better)
# are shown separately by gender, other covariates held at sample means.
# Gender differences are modest; overlapping CIs suggest no large gender gap
# in economic optimism in this sample.

# ==========================================================================
# 2. Multinomial logit: vote choice
# ==========================================================================

# ----------------------------------------------------------
# a) Set reference category and fit multinomial logit
# ----------------------------------------------------------

BEPS$vote = relevel(BEPS$vote, ref = "Conservative")
m_mlogit = multinom(vote ~ economic.cond.national + Blair + Hague +
                           Kennedy + Europe, data = BEPS, trace = FALSE)
summary(m_mlogit)

# Blair coefficient in the Labour vs. Conservative equation is strongly positive:
# higher Blair approval greatly increases log-odds of voting Labour over Conservative.
# Blair was the Labour leader in 1997, so this is expected and intuitive.
# The Blair coefficient in the Lib Dem vs. Conservative equation is much smaller.

# ----------------------------------------------------------
# b) Average marginal effects across all predictors and outcomes
# ----------------------------------------------------------

avg_slopes(m_mlogit)

# AME of Blair on P(vote = Labour) is positive and substantial:
# a one-unit increase in Blair approval is associated with a meaningful increase
# in the average probability of voting Labour, holding other variables constant.
# Reflects the strong leader-driven nature of vote choice in the 1997 British election.

# ----------------------------------------------------------
# c) IIA assumption
# ----------------------------------------------------------

# IIA: the odds ratio between any two alternatives is unaffected by the presence
# of other alternatives. Problematic when two parties are close substitutes.
# Labour and the Liberal Democrats are both centre-left, so some voters may
# treat them as partial substitutes — a moderate IIA concern.
# Conservatives occupy a clearly distinct ideological position, making IIA
# more defensible for comparisons involving them.
# Overall: IIA is plausible but should be treated with some caution for the
# Labour/Liberal Democrat distinction in this three-party setting.

# ==========================================================================
# 3. Poisson regression: publication counts
# ==========================================================================

data(bioChemists)

# ----------------------------------------------------------
# a) Explore outcome variable
# ----------------------------------------------------------

summary(bioChemists$art)
var(bioChemists$art)

ggplot(bioChemists, aes(x = art)) +
  geom_histogram(binwidth = 1, fill = "#294b66", color = "white") +
  theme_minimal() +
  labs(title = "Publications in last 3 years of PhD",
       x = "Number of articles", y = "Count")
ggsave("hist_art.pdf", width = 6, height = 4)

# Mean ~1.69, variance ~3.71 -- variance is roughly twice the mean.
# Under Poisson, variance should equal mean. Ratio >> 1 signals overdispersion.
# Distribution is right-skewed with a mode at zero and a long upper tail.

# ----------------------------------------------------------
# b) Fit Poisson regression
# ----------------------------------------------------------

m_pois = glm(art ~ fem + mar + kid5 + phd + ment,
             data = bioChemists, family = poisson)
summary(m_pois)

exp(coef(m_pois)["ment"])

# IRR for ment: each additional mentor article multiplies expected student
# articles by ~1.026. Modest but positive effect of mentor productivity.
# Residual deviance >> degrees of freedom (ratio well above 2): clear
# diagnostic of overdispersion in the Poisson model.

# ----------------------------------------------------------
# c) Formal overdispersion test
# ----------------------------------------------------------

dispersiontest(m_pois)

# z ~ 5.78, p < 0.001: strongly reject equidispersion.
# Estimated dispersion ~ 1.82 (variance ~1.82x the mean).
# Consequence: Poisson SEs are too small, p-values anti-conservative.
# A negative binomial model is needed.

# ==========================================================================
# 4. Negative binomial regression
# ==========================================================================

# ----------------------------------------------------------
# a) Fit negative binomial model
# ----------------------------------------------------------

m_nb = glm.nb(art ~ fem + mar + kid5 + phd + ment,
              data = bioChemists)
summary(m_nb)

# ment coefficient similar to Poisson, but SEs are wider (more honest).
# theta (overdispersion parameter) shown in summary: moderate overdispersion.
# Significant predictors: fem (negative), kid5 (negative), ment (positive).
# phd and mar are not statistically significant.

# ----------------------------------------------------------
# b) Compare model fit by AIC
# ----------------------------------------------------------

AIC(m_pois)
AIC(m_nb)

# NB AIC ~3136 vs Poisson AIC ~3314: NB is substantially better.
# Despite one extra parameter (theta), the improvement in fit far outweighs
# the complexity penalty. Overdispersion is real and worth addressing.

# ----------------------------------------------------------
# c) Predicted counts by gender at sample means
# ----------------------------------------------------------

predictions(m_nb, newdata = datagrid(fem = c("Men", "Women")))

# Men: predicted ~1.87 articles; Women: predicted ~1.51 articles.
# Gender gap is meaningful and statistically distinguishable (CIs do not overlap).
# Difference persists after conditioning on marital status, kids, PhD prestige,
# and mentor productivity -- a within-group productivity gap.

# ----------------------------------------------------------
# d) Summary
# ----------------------------------------------------------

# Poisson is inadequate: variance/mean ratio ~2.2, residual deviance >> df,
# and dispersiontest() rejects equidispersion (p < 0.001).
# Negative binomial adds a dispersion parameter, achieves AIC ~180 units lower,
# and produces more reliable (wider) standard errors.
# The mentor's IRR ~1.026 per additional mentor article: modest but positive --
# working with a productive mentor provides a small, real boost to student output.
# Significant predictors in NB: fem (negative), kid5 (negative), ment (positive).
# phd prestige and marital status are not significant.
# Substantive conclusion: early-career publication productivity in biochemistry
# is shaped by mentor environment, gender, and family demands -- consistent with
# broader literature on structural barriers facing women and parents in STEM PhD programs.
