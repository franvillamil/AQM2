# ==========================================================================
# Assignment 2: Applied Regression
# Applied Quantitative Methods II, UC3M
# ==========================================================================

library(dplyr)
library(broom)
library(ggplot2)
library(modelsummary)

# ==========================================================================
# Part 1: QoG Dataset
# ==========================================================================

# ----------------------------------------------------------
# 1. Setup and data preparation
# ----------------------------------------------------------

# a)
qog = read.csv("https://www.qogdata.pol.gu.se/data/qog_std_cs_jan26.csv")

df = qog %>%
  select(country = cname, epi = epi_epi, women_parl = wdi_wip,
         gov_eff = wbgi_gee, green_seats = cpds_lg)

# b)
nrow(df)

# c)
summary(df)

# ----------------------------------------------------------
# 2. Exploratory visualization
# ----------------------------------------------------------

# a-b)
ggplot(df, aes(x = women_parl, y = epi)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(x = "Women in Parliament (%)", y = "EPI Score")

# ----------------------------------------------------------
# 3. Bivariate regression
# ----------------------------------------------------------

# a)
m1 = lm(epi ~ women_parl, data = df)

# b)
tidy(m1)

# c)
p25 = quantile(df$women_parl, 0.25, na.rm = TRUE)
p75 = quantile(df$women_parl, 0.75, na.rm = TRUE)

coef(m1)["women_parl"] * (p75 - p25)

pred = predict(m1, newdata = data.frame(women_parl = c(p25, p75)))
pred[2] - pred[1]

# ----------------------------------------------------------
# 4. Multiple regression
# ----------------------------------------------------------

# a)
m2 = lm(epi ~ women_parl + gov_eff, data = df)
tidy(m2)

# ----------------------------------------------------------
# 5. Demonstrating OVB
# ----------------------------------------------------------

# a)
beta1_biva = tidy(m1) %>% filter(term == "women_parl") %>% pull(estimate)
beta1_mult = tidy(m2) %>% filter(term == "women_parl") %>% pull(estimate)
beta2_mult = tidy(m2) %>% filter(term == "gov_eff") %>% pull(estimate)

# b)
aux = lm(gov_eff ~ women_parl, data = df)
delta = tidy(aux) %>% filter(term == "women_parl") %>% pull(estimate)

# c)
round(beta1_mult + beta2_mult * delta, 4)
round(beta1_biva, 4)

# ----------------------------------------------------------
# 6. Robust standard errors
# ----------------------------------------------------------

# a)
modelsummary(m2)

# b)
modelsummary(m2, vcov = "robust")

# ----------------------------------------------------------
# 7. Presenting results
# ----------------------------------------------------------

# a)
modelsummary(list("Bivariate" = m1, "Multiple" = m2),
             vcov = "robust")

# b-c)
p = modelplot(list("Bivariate" = m1, "Multiple" = m2),
              vcov = "robust")
ggsave("coefplot_qog.png", p, width = 7, height = 4)

# ==========================================================================
# Part 2: STAR Dataset
# ==========================================================================

# ----------------------------------------------------------
# 1. Data preparation
# ----------------------------------------------------------

# a)
star = read.csv("https://raw.githubusercontent.com/franvillamil/AQM2/master/datasets/star/star.csv")

# b)
star$classtype = factor(star$classtype,
  levels = 1:3,
  labels = c("Small", "Regular", "Regular+Aide"))

# c)
star$race = factor(star$race,
  levels = 1:6,
  labels = c("White", "Black", "Asian", "Hispanic",
             "Native American", "Other"))

# d)
star$small = ifelse(star$classtype == "Small", 1, 0)

# e)
nrow(star)
sum(!is.na(star$g4reading))
sum(!is.na(star$g4math))

# ----------------------------------------------------------
# 2. Comparing groups
# ----------------------------------------------------------

# a)
star %>%
  group_by(classtype) %>%
  summarise(mean_reading = mean(g4reading, na.rm = TRUE))

# b)
m1 = lm(g4reading ~ small, data = star)
tidy(m1)

# c)
star %>%
  group_by(small) %>%
  summarise(mean_reading = mean(g4reading, na.rm = TRUE))

# d)
m1_math = lm(g4math ~ small, data = star)
tidy(m1_math)

# ----------------------------------------------------------
# 3. Adding controls
# ----------------------------------------------------------

# a)
m2 = lm(g4reading ~ small + race + yearssmall, data = star)
tidy(m2)

# ----------------------------------------------------------
# 4. Interactions
# ----------------------------------------------------------

# a)
m3 = lm(g4reading ~ small * race + yearssmall, data = star)

# b)
tidy(m3)

# c)
coef(m3)["small"]
coef(m3)["small"] + coef(m3)["small:raceBlack"]

# ----------------------------------------------------------
# 5. Presenting results
# ----------------------------------------------------------

# a)
modelsummary(
  list("Bivariate" = m1, "Controls" = m2, "Interaction" = m3),
  vcov = "robust")

# b-c)
p = modelplot(
  list("Bivariate" = m1, "Controls" = m2, "Interaction" = m3),
  vcov = "robust")
ggsave("coefplot_star.png", p, width = 7, height = 5)
