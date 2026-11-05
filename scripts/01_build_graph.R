# 01 - Build graph
# Nodes: the 4,604 Wikispeedia articles. Vertex names are the URL-encoded
#        article IDs used throughout the dataset.
# Edges: directed, unweighted hyperlink A -> B.
# Node attributes:
#   title     decoded article title
#   category  first listed category, e.g. "subject.Science.Biology"
#   topic     top-level topic, e.g. "Science"
#
# Outputs:
#   data/processed/graph.rds  igraph object
#   data/processed/paths.rds  human games (finished + unfinished), one row each
source(here::here("R/helpers.R"))

articles   <- read_wsp("articles.tsv",   "article")
links      <- read_wsp("links.tsv",      c("from", "to"))
categories <- read_wsp("categories.tsv", c("article", "category"))

primary_cat <- categories[, .SD[1], by = article]
primary_cat[, topic := tstrsplit(category, ".", fixed = TRUE)[[2]]]

nodes <- merge(articles, primary_cat, by = "article", all.x = TRUE)
nodes[, title := decode_title(article)]

g <- graph_from_data_frame(links, directed = TRUE, vertices = nodes)
saveRDS(g, processed_path("graph.rds"))
saveRDS(categories, processed_path("categories.rds"))

# `path` is a ';'-separated list of articles; "<" marks a back-click.
finished <- read_wsp("paths_finished.tsv",
                     c("player", "timestamp", "duration_s", "path", "rating"))
finished[, `:=`(finished = TRUE, type = NA_character_)]

unfinished <- read_wsp("paths_unfinished.tsv",
                       c("player", "timestamp", "duration_s", "path", "target", "type"))
unfinished[, finished := FALSE]

paths <- rbind(finished, unfinished, fill = TRUE)
paths[, steps := strsplit(path, ";", fixed = TRUE)]
paths[, `:=`(
  source      = vapply(steps, `[`, character(1), 1),
  target      = fifelse(finished, vapply(steps, function(s) s[length(s)], character(1)), target),
  n_clicks    = lengths(steps) - 1L,
  n_backtrack = vapply(steps, function(s) sum(s == "<"), integer(1))
)]
saveRDS(paths, processed_path("paths.rds"))

message(sprintf("Graph: %d nodes, %d edges. Paths: %d finished, %d unfinished.",
                vcount(g), ecount(g), nrow(finished), nrow(unfinished)))
