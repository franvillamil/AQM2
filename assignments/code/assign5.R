# setwd("~/Documents/AQM2")
options(stringsAsFactors = FALSE)

# ============================================================
# Assignment 5: Best Practices in Computing
# Applied Quantitative Methods II, UC3M
# ============================================================

# List of packages
library(readstata13)
library(modelsummary)
library(ggplot2)

# ==========================================================================
# Part 1: Project Organization (In-Class)
# ==========================================================================

# ----------------------------------------------------------
## 1. Folder structure

# mkdir -p assignment5/data assignment5/analysis/output assignment5/plots/output
# touch assignment5/Makefile assignment5/README.md
# touch assignment5/analysis/models.R assignment5/plots/figures.R

# ----------------------------------------------------------
## 2. Analysis script (analysis/models.R)

# a)
df = read.dta13("data/corruption.dta")

# b)
dep_var = "ti_cpi"
indep_var = "undp_gdp"

# c)
df = df[!is.na(df[[dep_var]]) & !is.na(df[[indep_var]]), ]
cat("Observations:", nrow(df), "\n")

# d)
if(nrow(df) < 10) stop("Too few observations")

# e)
m1 = lm(ti_cpi ~ undp_gdp, data = df)
m2 = lm(ti_cpi ~ log(undp_gdp), data = df)

# f)
modelsummary(
  list("Level" = m1, "Log" = m2),
  output = "analysis/output/table_models.tex",
  stars = TRUE,
  gof_map = c("r.squared", "nobs"))

# g)
cat("Analysis complete. Table saved.\n")

# ----------------------------------------------------------
## 3. Plots script (plots/figures.R)

# a)
df = read.dta13("data/corruption.dta")
df = df[!is.na(df$ti_cpi) & !is.na(df$undp_gdp), ]

# b-c)
p = ggplot(df, aes(x = log(undp_gdp), y = ti_cpi)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(
    x = "Log GDP per capita (PPP)",
    y = "Corruption Perceptions Index",
    title = "Corruption and Wealth") +
  theme_minimal()

# d)
ggsave("plots/output/scatter_corruption.pdf", p, width = 7, height = 5)

# e)
cat("Scatter plot saved.\n")

# ----------------------------------------------------------
## 4. Makefile

# all: analysis/output/table_models.tex plots/output/scatter_corruption.pdf
#
# analysis/output/table_models.tex: analysis/models.R data/corruption.dta
# 	Rscript --no-save analysis/models.R
#
# plots/output/scatter_corruption.pdf: plots/figures.R data/corruption.dta
# 	Rscript --no-save plots/figures.R

# ==========================================================================
# Part 2: Code Quality and Git (Take-Home)
# ==========================================================================

# ----------------------------------------------------------
## 1. Improved script (improved_script.R)

start_year = 2000
end_year = 2020

panel = read.csv("mydata.csv")

if(nrow(panel) == 0) stop("Dataset is empty")
expected_cols = c("year", "outcome", "gdp", "pop", "education", "health")
missing_cols = setdiff(expected_cols, names(panel))
if(length(missing_cols) > 0) stop("Missing columns: ", paste(missing_cols, collapse = ", "))

panel = panel[panel$year >= start_year & panel$year <= end_year, ]
cat("Rows after filtering:", nrow(panel), "\n")

m_base = lm(outcome ~ gdp + pop, data = panel)
m_educ = lm(outcome ~ gdp + pop + education, data = panel)
m_full = lm(outcome ~ gdp + pop + education + health, data = panel)

modelsummary(
  list("Base" = m_base, "Education" = m_educ, "Full" = m_full),
  stars = TRUE,
  gof_map = c("r.squared", "nobs"))

save_scatter = function(data, xvar, yvar, filename) {
  pdf(filename, width = 7, height = 5)
  plot(data[[xvar]], data[[yvar]],
    xlab = xvar, ylab = yvar,
    pch = 16, col = rgb(0, 0, 0, 0.5))
  dev.off()
}

save_scatter(panel, "gdp", "outcome", "fig_gdp.pdf")
save_scatter(panel, "education", "outcome", "fig_education.pdf")

# ----------------------------------------------------------
## 2. Git practices

# .gitignore:
# *.pdf
# *.aux
# *.log
# .DS_Store
# analysis/output/
# plots/output/

# Example commit messages:
# Add folder structure and README for assignment 5
# Create analysis script with regression models
# Add plots script with scatter plot
# Add Makefile to automate pipeline
# Add improved script and .gitignore
