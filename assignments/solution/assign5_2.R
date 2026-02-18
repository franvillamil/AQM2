# setwd("~/Documents/AQM2")
options(stringsAsFactors = FALSE)

# ============================================================
# Assignment 5 -- Part 2: Improved Script
# Applied Quantitative Methods II, UC3M
# ============================================================

# ============================================================
# Load packages
# ============================================================

library(modelsummary)

# ============================================================
# Constants (Improvement 2)
# ============================================================

start_year = 2000
end_year = 2020

# ============================================================
# Load and clean data
# ============================================================

# Improvement 1: meaningful variable name instead of 'x'
panel = read.csv("mydata.csv")

# Improvement 5: assertion after loading
if(nrow(panel) == 0) stop("Dataset is empty")
expected_cols = c("year", "outcome", "gdp", "pop", "education", "health")
missing_cols = setdiff(expected_cols, names(panel))
if(length(missing_cols) > 0) stop("Missing columns: ", paste(missing_cols, collapse = ", "))

# Filter to analysis period using constants
panel = panel[panel$year >= start_year & panel$year <= end_year, ]

# Improvement 7: diagnostic print after filtering
cat("Rows after filtering:", nrow(panel), "\n")

# ============================================================
# Estimate models
# Improvement 6: spaces around operators, data = argument
# ============================================================

# Improvement 1: meaningful model names
m_base = lm(outcome ~ gdp + pop, data = panel)
m_educ = lm(outcome ~ gdp + pop + education, data = panel)
m_full = lm(outcome ~ gdp + pop + education + health, data = panel)

# Print summary table
modelsummary(
  list("Base" = m_base, "Education" = m_educ, "Full" = m_full),
  stars = TRUE,
  gof_map = c("r.squared", "nobs"))

# ============================================================
# Scatter plots
# Improvement 4: function to avoid repeating pdf/plot/dev.off
# ============================================================

save_scatter = function(data, xvar, yvar, filename) {
  pdf(filename, width = 7, height = 5)
  plot(data[[xvar]], data[[yvar]],
    xlab = xvar, ylab = yvar,
    pch = 16, col = rgb(0, 0, 0, 0.5))
  dev.off()
  cat("Saved:", filename, "\n")
}

save_scatter(panel, "gdp", "outcome", "fig_gdp.pdf")
save_scatter(panel, "education", "outcome", "fig_education.pdf")
