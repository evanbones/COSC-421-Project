# Heuristic Navigation in the Wikipedia Network

COSC 421 group project: Cohen Kucher, Jaden Anderson, Evan Bowness.

## Setup

1. Open `COSC421-Wikipedia.Rproj` in RStudio (or run R from the repo root).
2. `source("install_packages.R")`

## Data

[Wikispeedia](https://snap.stanford.edu/data/wikispeedia.html) (West & Leskovec, SNAP). It contains:

- 4,604 articles (a 2007 Wikipedia for Schools subset)
- about 120k directed links between them
- a category tree for each article
- about 76k human games of the Wikipedia Game, both finished and abandoned, with back-clicks recorded

`scripts/00_get_data.R` downloads it to `data/raw/`. `scripts/01_build_graph.R` saves these to `data/processed/`:

- `graph.rds`: the igraph object, with `title`, `category` and `topic` vertex attributes
- `paths.rds`: the human games
- `categories.rds`: every article–category pair

Article names are URL-encoded in the files and are used as vertex names. `title` is the decoded form.

## Pipeline

Run the scripts in order from the project root. Each one reads from `data/` and writes to `data/processed/` or `output/`.

| Script | Purpose |
|---|---|
| `scripts/00_get_data.R` | Download Wikispeedia to `data/raw/` |
| `scripts/01_build_graph.R` | Build the igraph object, save `data/processed/graph.rds` |
| `scripts/02_baseline.R` | Size, density, reciprocity, degree distributions |
| `scripts/03_q1_centrality.R` | Q1: centrality and waypoint hubs |
| `scripts/04_q2_components.R` | Q2: sinks and components |
| `scripts/05_q3_categories.R` | Q3: cross-category connectivity |
| `scripts/06_q4_navigation.R` | Q4: hub-first vs. standard greedy |

## Layout

```
R/             shared helper functions (sourced by every script)
scripts/       numbered analysis pipeline
data/raw/      downloaded data (git-ignored)
data/processed/ derived graph objects (git-ignored)
output/        figures and tables
report/        final report
```
