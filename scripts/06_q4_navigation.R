# 06 - Q4: Two-phase (hub-first) greedy vs. standard greedy navigation
# Compare path length / success rate between strategies.
# Human baseline: load_paths() has every Wikispeedia game, including clicks,
# back-clicks (n_backtrack), and abandoned games (finished == FALSE).
source(here::here("R/helpers.R"))
g     <- load_graph()
paths <- load_paths()

# TODO
