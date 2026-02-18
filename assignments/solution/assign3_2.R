# setwd("~/Documents/AQM2")
options(stringsAsFactors = FALSE)

# ============================================================
# Assignment 3 -- Part 2: STAR --- High School Graduation
# Applied Quantitative Methods II, UC3M
# ============================================================

# List of packages
library(dplyr)
library(broom)
library(ggplot2)
library(modelsummary)
library(marginaleffects)

# --------
## 1. Data preparation

# a) Load and create factor variables
star = read.csv("https://raw.githubusercontent.com/franvillamil/AQM2/refs/heads/master/datasets/star/star.csv")

star$classtype = factor(star$classtype,
  levels = 1:3,
  labels = c("Small", "Regular", "Regular+Aide"))

star$race = factor(star$race,
  levels = 1:6,
  labels = c("White", "Black", "Asian", "Hispanic",
             "Native American", "Other"))

# b) Create binary small indicator
star$small = ifelse(star$classtype == "Small", 1, 0)

# c) Drop observations with missing hsgrad
df = star %>% filter(!is.na(hsgrad))
nrow(df)

# d) Graduation rate overall and by class type
mean(df$hsgrad)

df %>%
  group_by(classtype) %>%
  summarise(grad_rate = mean(hsgrad), n = n())

# Students in small classes have a slightly higher graduation rate.

# --------
## 2. LPM and logit

# a) LPM
lpm1 = lm(hsgrad ~ small, data = df)
tidy(lpm1)

# b) Logit
logit1 = glm(hsgrad ~ small, family = binomial, data = df)
tidy(logit1)

# c) The LPM coefficient on small is the estimated difference in graduation
# probability between small and non-small classes. Because this is
# experimental data, it has a causal interpretation.

# d) AME from logit
avg_slopes(logit1)
# The AME is very close to the LPM coefficient.

# --------
## 3. Adding controls

# a) Controlled models
lpm2 = lm(hsgrad ~ small + race + yearssmall, data = df)
logit2 = glm(hsgrad ~ small + race + yearssmall,
             family = binomial, data = df)

# b) Compare bivariate and controlled coefficients on small
tidy(lpm1) %>% filter(term == "small") %>% select(term, estimate)
tidy(lpm2) %>% filter(term == "small") %>% select(term, estimate)
# The coefficient changes little, consistent with successful randomization.

# c) Interpret yearssmall from logit
tidy(logit2)
avg_slopes(logit2, variables = "yearssmall")
# Each additional year in a small class is associated with a higher probability
# of graduating. The AME converts the log-odds to the probability scale.

# --------
## 4. Predicted probabilities

# a) Predictions for specific profiles
predictions(logit2,
  newdata = datagrid(
    small = c(1, 0),
    race = c("White", "Black"),
    yearssmall = c(3, 0)))

# b) Plot across yearssmall by small
p1 = plot_predictions(logit2, condition = c("yearssmall", "small"))
ggsave("pred_prob_yearssmall.png", p1, width = 6, height = 4)

# --------
## 5. Interactions

# a) Interaction model
logit3 = glm(hsgrad ~ small * race + yearssmall,
             family = binomial, data = df)

# b) Marginal effect of small by race
avg_slopes(logit3, variables = "small", by = "race")

# c) The small class effect differs across racial groups. Some groups show
# a larger benefit, though confidence intervals are wide for groups with
# fewer observations. The results suggest the benefits may not be uniform.

# --------
## 6. Presenting results and discussion

# a) Comparison table
modelsummary(
  list("LPM biv." = lpm1, "LPM ctrl." = lpm2,
       "Logit biv." = logit1, "Logit ctrl." = logit2),
  vcov = list("robust", "robust", NULL, NULL))

# b) Coefficient plot
p2 = modelplot(
  list("LPM biv." = lpm1, "LPM ctrl." = lpm2,
       "Logit biv." = logit1, "Logit ctrl." = logit2),
  vcov = list("robust", "robust", NULL, NULL))
ggsave("coefplot_star.png", p2, width = 6, height = 4)

# c) Discussion:
# The STAR data provide experimental evidence that small class sizes have a
# positive effect on high school graduation. The estimated effect is modest
# but consistent across specifications.
#
# The LPM and logit results are very similar, both in magnitude and
# significance. This is expected when the outcome probability is not extreme.
# The similarity confirms that functional form assumptions make little
# practical difference here.
#
# This experimental evidence is more credible than observational studies
# because random assignment eliminates confounders by design. In observational
# data, class size correlates with school resources, neighborhood
# characteristics, and student composition. The stability of the small-class
# coefficient when controls are added further supports successful
# randomization.
