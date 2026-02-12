# ==========================================================================
# Assignment 2, Part 2: STAR Dataset
# ==========================================================================

library(dplyr)
library(broom)
library(ggplot2)
library(modelsummary)

# ----------------------------------------------------------
# 2.1 Data preparation
# ----------------------------------------------------------

# a) Load data
star = read.csv("https://raw.githubusercontent.com/franvillamil/AQM2/master/datasets/star.csv")

# b) Factor for class type
star$classtype = factor(star$classtype,
  levels = 1:3,
  labels = c("Small", "Regular", "Regular+Aide"))

# c) Factor for race
star$race = factor(star$race,
  levels = 1:6,
  labels = c("White", "Black", "Asian", "Hispanic",
             "Native American", "Other"))

# d) Binary indicator
star$small = ifelse(star$classtype == "Small", 1, 0)

# e) Observations
nrow(star)
sum(!is.na(star$g4reading))
sum(!is.na(star$g4math))

# ----------------------------------------------------------
# 2.2 Comparing groups
# ----------------------------------------------------------

# a) Mean reading by class type
star %>%
  group_by(classtype) %>%
  summarise(mean_reading = mean(g4reading, na.rm = TRUE))

# b) Bivariate regression
m1 = lm(g4reading ~ small, data = star)
tidy(m1)
# Coefficient = avg difference small vs. non-small (causal, experimental)

# c) Verify: regression coef equals difference in group means
star %>%
  group_by(small) %>%
  summarise(mean_reading = mean(g4reading, na.rm = TRUE))

# d) Repeat for math
m1_math = lm(g4math ~ small, data = star)
tidy(m1_math)

# ----------------------------------------------------------
# 2.3 Adding controls
# ----------------------------------------------------------

# a) Multiple regression
m2 = lm(g4reading ~ small + race + yearssmall, data = star)
tidy(m2)

# b) Coefficient on small should be similar to bivariate model,
#    confirming successful randomization.

# c) yearssmall captures cumulative benefit of additional years
#    spent in a small class.

# ----------------------------------------------------------
# 2.4 Interactions
# ----------------------------------------------------------

# a) Interaction model
m3 = lm(g4reading ~ small * race + yearssmall, data = star)

# b) Print results
tidy(m3)

# c) Effect for White students = coef on "small"
#    Effect for Black students = coef on "small" + coef on "small:raceBlack"
coef(m3)["small"]
coef(m3)["small"] + coef(m3)["small:raceBlack"]

# d) Some evidence that minority students may benefit more,
#    but interactions may not be statistically significant.

# ----------------------------------------------------------
# 2.5 Presenting results
# ----------------------------------------------------------

# a) Table
modelsummary(
  list("Bivariate" = m1, "Controls" = m2, "Interaction" = m3),
  vcov = "robust")

# b) Coefficient plot
p = modelplot(
  list("Bivariate" = m1, "Controls" = m2, "Interaction" = m3),
  vcov = "robust")
p

# c) Save
ggsave("coefplot_star.png", p, width = 7, height = 5)
modelsummary(
  list("Bivariate" = m1, "Controls" = m2, "Interaction" = m3),
  vcov = "robust",
  output = "table_star.png")

# ----------------------------------------------------------
# 2.6 Discussion
# ----------------------------------------------------------

# a) Small classes have a positive effect on both reading and math scores.
# b) Credible because of random assignment -- eliminates confounders.
# c) Limitations: attrition, possible non-compliance, generalizability
#    (Tennessee 1980s context).
