# ==========================================================================
# Assignment 2, Part 1: QoG Dataset
# ==========================================================================

library(dplyr)
library(broom)
library(ggplot2)
library(modelsummary)

# ----------------------------------------------------------
# 1.1 Setup and data preparation
# ----------------------------------------------------------

# a) Load and rename
qog = read.csv("https://www.qogdata.pol.gu.se/data/qog_std_cs_jan26.csv")

df = qog %>%
  select(country = cname, epi = epi_epi, women_parl = wdi_wip,
         gov_eff = wbgi_gee, green_seats = cpds_lg)

# b) Drop missing values
df = df %>% na.omit()
nrow(df)

# c) Summary statistics
summary(df)

# ----------------------------------------------------------
# 1.2 Exploratory visualization
# ----------------------------------------------------------

# a-b) Scatter plot with linear fit
ggplot(df, aes(x = women_parl, y = epi)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(x = "Women in Parliament (%)", y = "EPI Score")

# c) Positive relationship: countries with more women in parliament
#    tend to have higher EPI scores.

# ----------------------------------------------------------
# 1.3 Bivariate regression
# ----------------------------------------------------------

# a) Bivariate model
m1 = lm(epi ~ women_parl, data = df)

# b) Extract results
tidy(m1)

# c) Predicted difference at IQR
iqr = quantile(df$women_parl, 0.75) - quantile(df$women_parl, 0.25)
coef(m1)["women_parl"] * iqr

# ----------------------------------------------------------
# 1.4 Multiple regression
# ----------------------------------------------------------

# a) Add gov_eff
m2 = lm(epi ~ women_parl + gov_eff, data = df)
tidy(m2)

# b) The coefficient on women_parl decreases when gov_eff is added,
#    suggesting part of the bivariate association was confounded by
#    government effectiveness.

# ----------------------------------------------------------
# 1.5 Demonstrating OVB
# ----------------------------------------------------------

# a) Extract coefficients
beta1_biva = tidy(m1) %>% filter(term == "women_parl") %>% pull(estimate)
beta1_mult = tidy(m2) %>% filter(term == "women_parl") %>% pull(estimate)
beta2_mult = tidy(m2) %>% filter(term == "gov_eff") %>% pull(estimate)

# b) Auxiliary regression
aux = lm(gov_eff ~ women_parl, data = df)
delta = tidy(aux) %>% filter(term == "women_parl") %>% pull(estimate)

# c) Verify OVB formula
round(beta1_mult + beta2_mult * delta, 2)
round(beta1_biva, 2)

# d) The bias is positive because gov_eff is positively correlated
#    with both women_parl and epi.

# ----------------------------------------------------------
# 1.6 Robust standard errors
# ----------------------------------------------------------

# a) Classical SEs
modelsummary(m2)

# b) Robust SEs
modelsummary(m2, vcov = "robust")

# c) SEs may differ somewhat but conclusions typically don't change.

# ----------------------------------------------------------
# 1.7 Presenting results
# ----------------------------------------------------------

# a) Side-by-side table
modelsummary(list("Bivariate" = m1, "Multiple" = m2),
             vcov = "robust")

# b) Coefficient plot
p = modelplot(list("Bivariate" = m1, "Multiple" = m2),
              vcov = "robust")
p

# c) Save
ggsave("coefplot_qog.png", p, width = 7, height = 4)

# ----------------------------------------------------------
# 1.8 Effect size
# ----------------------------------------------------------

# Compare predicted change for 1 SD shift in women_parl to the SD of epi.
# Or standardize both variables and re-run the regression.
