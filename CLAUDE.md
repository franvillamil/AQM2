# CLAUDE.md — Project Conventions for AQMSS-II

This file documents the conventions, structure, and style rules for the Applied Quantitative Methods for the Social Sciences II (AQMSS-II) course materials. Use this as a reference when creating or editing slides, assignments, or other course documents.

---

## Project Structure

```
advanced_quant/
├── slides/                         # Lecture slides (Beamer LaTeX)
│   ├── beamer_preamble.tex         # Shared preamble for all slide decks
│   ├── beamer_notes_preamble.tex   # Additional preamble for notes versions
│   ├── 01_introduction/
│   ├── 02_applied_regression/
│   ├── 03_binary_outcomes/
│   └── ...
├── assignments/                    # Assignment documents (LaTeX articles)
│   ├── preamble.tex                # Shared preamble for all assignments
│   ├── assign1_introduction.tex
│   ├── assign2_applied_regression.tex
│   ├── assign3_binary_outcomes.tex
│   └── ...
├── myrefs/                         # Reference documents (outlines, specs)
│   ├── AQMSS_II_working_outline.md # Authoritative content guide
│   └── ...
├── index.md                        # GitHub Pages homepage
├── sessions.md                     # Session descriptions
└── _config.yml                     # Jekyll configuration
```

---

## Slides (Beamer)

### File structure per session

Each session has its own directory under `slides/` with three files:

1. **`<topic>.tex`** — Main wrapper (~14 lines). Sets documentclass, title, author, date, inputs preamble and body.
2. **`<topic>_notes.tex`** — Notes wrapper (~15 lines). Same as above but adds `handout` option and inputs `beamer_notes_preamble.tex`.
3. **`<topic>_body.tex`** — All content. This is where slides are written.

### Wrapper file template (presentation)

```latex
\documentclass[aspectratio=43]{beamer}

% Title --------------------------------------------
\title{\huge Session Title}
\author{Francisco Villamil}
\date{Applied Quantitative Methods II\\IC3JM, Spring 2026}

\input{../beamer_preamble.tex}

\begin{document}

\input{<topic>_body}

\end{document}
```

### Wrapper file template (notes)

Same as above but with `handout` option and notes preamble:

```latex
\documentclass[aspectratio=43,handout]{beamer}
...
\input{../beamer_preamble.tex}
\input{../beamer_notes_preamble.tex}
...
```

### Body file conventions

- Start with `\titlepage` frame
- Use `% ====================================================` as section separators
- Use `% ----------------------------------------------------` as frame separators
- Every frame must be followed by `\note{}` (even if empty)
- Use `\transitionframe` environment for section title slides
- Use `[<+->]` on `\begin{itemize}` or `\begin{enumerate}` for progressive reveals
- Use `\item[]` for blank spacer items between groups
- Sections defined with `\section{Name}` auto-generate roadmap frames

### Math notation

- Display math: `$$...$$`
- Inline math: `$...$`
- Consistent symbols: $Y$ (outcome), $X$ (predictor), $\beta$ (coefficients), $\varepsilon$ (error)
- Use `\vspace{10pt}` or `\vspace{20pt}` for spacing around display math

### Available custom commands (from beamer_preamble.tex)

- `\red{text}` — red text (accent2 color)
- `\yellow{text}` — yellow text
- `\asher{text}` — gray text
- `\BGyellow{text}` — yellow background highlight
- `\BGred{text}` — red background highlight
- All support overlay specs: `\BGyellow<2>{text}` highlights only on slide 2
- `\transitionframe` — colored section divider frame
- `\imageframe{filename}` — full-page image

### Closing frames pattern

Every session body should end with:
1. "Summary: Key takeaways" frame
2. "For next week" frame (readings matching working outline, mention next assignment)
3. "Questions?" frame (empty frametitle)

---

## Assignments

### File naming

- Files are named `assign<N>_<topic>.tex` (e.g., `assign2_applied_regression.tex`)
- Located in the `assignments/` directory

### Preamble

All assignments use `\input{preamble.tex}` which provides:
- Document class: `article`, 12pt, A4 paper
- Margins: 2cm (geometry package)
- Font: Palatino (`\rmdefault{ppl}`)
- Line spacing: 1.2 (`\setstretch{1.2}`)
- Code blocks: `lstlisting` with gray background, single frame
- Inline code: `\code{text}` command (maps to `\texttt{}`)
- Enumeration: `enumitem` package available

### Document structure

```latex
\input{preamble.tex}

\begin{document}

\thispagestyle{empty}

\begin{center}
\textbf{\Large Assignment N: Title}\\\vspace{10pt}
{\Large Applied Quantitative Methods for the Social Sciences II}\\\vspace{10pt}
Carlos III--Juan March Institute, Spring 2026
\end{center}

\vspace{10pt}
\noindent
\textbf{\large Instructions:}

\vspace{10pt}
\begin{itemize}
\setlength\itemsep{0pt}
  \item {\color{red}{\textbf{Deadline}}}: \textbf{Date, before class}
  \item ...instructions...
\end{itemize}

\vspace{20pt}

\section{...}
...

\end{document}
```

### Style rules

- Title: "Assignment N" (not "Problem Set")
- Deadline in **red bold**: `{\color{red}{\textbf{Deadline}}}` followed by bold date
- Use `\section{}` for main tasks/parts
- Use `\subsection{}` for sub-sections
- Use `\enumerate[label=\alph*)]` for lettered sub-questions
- Use `\lstlisting` for code blocks
- Use `\code{}` for inline code references
- Each main task/section should start on a new page (`\newpage` before `\section{}`)
- If the assignment needs math, add `\usepackage{amsmath}` after the preamble input

### Terminology

- Use "assignment" (not "problem set") throughout
- Use "Assignment N" for titles (not "PS N")
- File submission references should match: `assign<N>.R`

---

## Working Outline

The file `myrefs/AQMSS_II_working_outline.md` is the **authoritative guide** for session content, readings, and due dates. Always consult it when creating or revising materials. It contains:

- Session-by-session content outlines with timing
- Required readings per session
- Assignment topics and due dates
- Key R packages per session

---

## Compilation

- Slides: `pdflatex <topic>.tex` from the session directory
- Notes: `pdflatex <topic>_notes.tex` from the session directory
- Assignments: `pdflatex assign<N>_<topic>.tex` from the `assignments/` directory
- All files should compile cleanly with a single `pdflatex` pass (no bibliography currently in use)

---

## General Style

- Course name: "Applied Quantitative Methods for the Social Sciences II" (full) or "AQMSS-II" (short)
- Institution: "Carlos III--Juan March Institute" (with en-dash)
- Semester: "Spring 2026"
- Author: "Francisco Villamil"
- R code style: tidyverse conventions, `library()` calls at top of scripts
- Key R packages used across the course: `broom`, `modelsummary`, `marginaleffects`, `ggplot2`, `dplyr`
- Preferred IDE: Positron (but assignments include instructions for RStudio and Sublime Text 4 as alternatives)
