# setwd("~/Documents/AQM2")
options(stringsAsFactors = FALSE)

# ============================================================
# Assignment 5 -- Part 1: Project Organization (In-Class)
# Applied Quantitative Methods II, UC3M
# ============================================================

# List of packages
library(readstata13)
library(modelsummary)
library(ggplot2)

# ============================================================
# 1. Folder structure
# ============================================================

# Created from terminal:
# mkdir -p assignment5/data assignment5/analysis/output assignment5/plots/output
# touch assignment5/Makefile assignment5/README.md
# touch assignment5/analysis/models.R assignment5/plots/figures.R

# ============================================================
# 2. Analysis script (analysis/models.R)
# ============================================================

# --- Full content of analysis/models.R ---

# # setwd("~/path/to/assignment5")
# options(stringsAsFactors = FALSE)
#
# library(readstata13)
# library(modelsummary)
#
# df = read.dta13("data/corruption.dta")
#
# dep_var = "ti_cpi"
# indep_var = "undp_gdp"
#
# df = df[!is.na(df[[dep_var]]) & !is.na(df[[indep_var]]), ]
# cat("Observations:", nrow(df), "\n")
#
# if(nrow(df) < 10) stop("Too few observations")
#
# m1 = lm(ti_cpi ~ undp_gdp, data = df)
# m2 = lm(ti_cpi ~ log(undp_gdp), data = df)
#
# modelsummary(
#   list("Level" = m1, "Log" = m2),
#   output = "analysis/output/table_models.tex",
#   stars = TRUE,
#   gof_map = c("r.squared", "nobs"))
#
# cat("Analysis complete. Table saved.\n")

# --- Verification (runs inline) ---

df = read.dta13("https://raw.githubusercontent.com/franvillamil/AQM2/refs/heads/master/datasets/other/corruption.dta")

dep_var = "ti_cpi"
indep_var = "undp_gdp"

df = df[!is.na(df[[dep_var]]) & !is.na(df[[indep_var]]), ]
cat("Observations:", nrow(df), "\n")

if(nrow(df) < 10) stop("Too few observations")

m1 = lm(ti_cpi ~ undp_gdp, data = df)
m2 = lm(ti_cpi ~ log(undp_gdp), data = df)

modelsummary(
  list("Level" = m1, "Log" = m2),
  stars = TRUE,
  gof_map = c("r.squared", "nobs"))

# ============================================================
# 3. Plots script (plots/figures.R)
# ============================================================

# --- Full content of plots/figures.R ---

# # setwd("~/path/to/assignment5")
# options(stringsAsFactors = FALSE)
#
# library(readstata13)
# library(ggplot2)
#
# df = read.dta13("data/corruption.dta")
# df = df[!is.na(df$ti_cpi) & !is.na(df$undp_gdp), ]
#
# p = ggplot(df, aes(x = log(undp_gdp), y = ti_cpi)) +
#   geom_point() +
#   geom_smooth(method = "lm") +
#   labs(
#     x = "Log GDP per capita (PPP)",
#     y = "Corruption Perceptions Index",
#     title = "Corruption and Wealth") +
#   theme_minimal()
#
# ggsave("plots/output/scatter_corruption.pdf", p, width = 7, height = 5)
#
# cat("Scatter plot saved.\n")

# ============================================================
# 4. Makefile
# ============================================================

# all: analysis/output/table_models.tex plots/output/scatter_corruption.pdf
#
# analysis/output/table_models.tex: analysis/models.R data/corruption.dta
# 	Rscript --no-save analysis/models.R
#
# plots/output/scatter_corruption.pdf: plots/figures.R data/corruption.dta
# 	Rscript --no-save plots/figures.R
