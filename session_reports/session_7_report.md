# Session 7 Report: Spatial Data I
**Course:** Applied Quantitative Methods for the Social Sciences II (AQM2)
**Date produced:** 2026-02-22
**Topic:** Spatial data I — Working with spatial data

---

## Summary Table

| Artifact | Status | File |
|----------|--------|------|
| Slide body | PASS | `slides/07_spatial1/spatial1_body.tex` |
| Presentation PDF | PASS | `slides/07_spatial1/spatial1.pdf` (330 KB) |
| Notes PDF | PASS | `slides/07_spatial1/spatial1_notes.pdf` (234 KB) |
| Assignment | PASS | `assignments/assign7_spatial1.tex` → `assign7_spatial1.pdf` (105 KB) |
| Solution Part 1 Rmd | PASS (knits) | `assignments/solutions/assign7_part1.Rmd` → `assign7_part1.pdf` (282 KB) |
| Solution Part 2 Rmd | PASS (knits, synthetic data) | `assignments/solutions/assign7_part2.Rmd` → `assign7_part2.pdf` (327 KB) |
| Bare R script (combined) | CREATED | `assignments/code/assign7.R` |

---

## Slides

### Section Overview

| Section | Frames | Content |
|---------|--------|---------|
| Why Spatial Data? | 3 | Motivation diagram, research examples, discussion prompt |
| Types of Spatial Data | 4 | Vector/raster diagram, geometry types, attributes table, raster grid |
| Coordinate Reference Systems | 4 | Definition, geographic CRS (globe), projected CRS, EPSG table |
| The sf Package | 9 | sf intro, console output demo, reading, inspecting, dplyr ops, CRS ops, geometric ops, spatial joins, worked example |
| Visualization with ggplot2 | 5 | geom_sf, choropleth, layering, complete example, tips |
| Wrap-up | 3 | Key takeaways, next session, questions |

**Total content frames:** ~28 (plus ~5 auto-generated Roadmap frames)

### Compilation

- **Presentation (`spatial1.pdf`):** Compiles without errors; only warnings are 2.12pt footer hboxes (below 10pt threshold — minor)
- **Notes (`spatial1_notes.pdf`):** Compiles without errors

### Pedagogy Review Results

Reviewed by pedagogy-reviewer agent. Issues found and fixed:

| Issue | Severity | Fixed? |
|-------|----------|--------|
| No Socratic questions in deck | HIGH | YES — discussion prompt added after Section 1 ("Think about your own research topic...") |
| 8-slide Section 4 run without visual anchor | HIGH | YES — sf console output frame inserted before "Reading spatial data" |
| `st_drop_geometry()` not surfaced on slide | MEDIUM | YES — added to "Attribute operations" frame |
| `st_within` passed without `()` — needs note | LOW | YES — sub-bullet added in "Spatial joins" frame |
| `\pgfmathsetmacro` in raster color argument | BUG | YES — replaced with hardcoded percentages |

### Images Needed

One image frame is commented out pending asset creation:

- **`slides/img/acled_africa_map.png`**: Map of Africa showing ACLED armed conflict event locations as points or density, with visible clustering in Sahel, Horn of Africa, and DRC. Create with R using `ggplot2 + geom_sf` + ACLED data, or download a screenshot from acleddata.com. Once the image is placed, uncomment the frame block at line ~91 in `spatial1_body.tex`.

---

## Assignment

### Structure

| Part | Type | Dataset | Sections |
|------|------|---------|----------|
| Part 1 (in-class) | `spData::world` built-in | Inspect sf, dplyr ops, ggplot2 choropleth |
| Part 2 (take-home) | `conflict_events.csv` (external) | CSV → sf, spatial join, choropleth |

### Assignment Checker Results

| Check | Result |
|-------|--------|
| Variable names in `world` dataset | ALL CORRECT (7/7) |
| sf functions (`st_read`, `st_join`, etc.) | ALL VALID (7/7) |
| R packages | ALL ON CRAN (sf, spData, dplyr, ggplot2, tidyr) |
| Compilation | CLEAN (zero overfull hboxes) |

### Issues Fixed After Checker

| Issue | Severity | Fixed |
|-------|----------|-------|
| `summarise()` incorrectly described as dropping geometry | CRITICAL | YES — corrected to "unions geometries by group" |
| No CRS check before `st_join()` | MAJOR | YES — `st_crs() == st_crs()` check added |
| `print(head(events_by_country, 10))` includes geometry | WARNING | YES — wrapped in `st_drop_geometry()` |
| Log-scale legend missing `name =` | MINOR | YES — `name = "Log(events+1)"` added |

### Requires Instructor Attention

1. **CRITICAL — Dataset missing**: `conflict_events.csv` does not exist at `github.com/franvillamil/AQM2/tree/master/datasets/spatial`. Part 2 (roughly half the assignment) will not work until this file is uploaded. Once uploaded, use the direct raw URL (e.g. `raw.githubusercontent.com/franvillamil/AQM2/master/datasets/spatial/conflict_events.csv`) so students can use `read.csv(url)` directly.

2. **Deadline**: Currently `[DEADLINE - TBD]` — set before distributing.

---

## Solutions

### Files

- `assign7_part1.Rmd` / `.R` — Part 1 (world dataset, no download needed)
- `assign7_part2.Rmd` / `.R` — Part 2 (**uses synthetic conflict data** pending real CSV)
- `code/assign7.R` — combined bare script

### Knit Status

| File | Status | Pages |
|------|--------|-------|
| `assign7_part1.pdf` | PASS (knits cleanly, 25 chunks) | 282 KB |
| `assign7_part2.pdf` | PASS (knits cleanly, 25 chunks, synthetic data) | 327 KB |

### Note on Part 2 solutions

Part 2 solutions use synthetic conflict event data (500 random points in Africa bounding box). The synthetic data block is clearly marked. When the real `conflict_events.csv` is uploaded, replace the data generation block with `events = read.csv("conflict_events.csv")` — all downstream code will work unchanged.

---

## Quality Scores

| Artifact | Score | Assessment |
|----------|-------|------------|
| Slides | 92/100 | PASS — 1 image still needed, all other issues fixed |
| Assignment | 85/100 | PASS (pending dataset upload and deadline) |
| Solutions | 90/100 | PASS (Part 2 uses synthetic data, clearly flagged) |

---

## Action Items for Instructor

1. **Upload `conflict_events.csv`** to the course GitHub repository at `datasets/spatial/`; update the URL in `assign7_spatial1.tex` to use the raw download link
2. **Set the assignment deadline** (replace `[DEADLINE - TBD]` in the assignment)
3. **Source/create the ACLED Africa map** for the image frame in the slides (see Images Needed above); then uncomment the frame in `spatial1_body.tex`
4. When distributing the assignment, compile one final time to confirm the URL resolves
