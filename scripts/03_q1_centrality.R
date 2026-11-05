# 03 - Q1: Which centrality metrics best identify waypoint hubs?
# Degree, PageRank, HITS, eigenvector, Katz, betweenness, closeness.
# Does routing through top hubs shorten paths?
#
# A "waypoint hub" is measured from the human games: how often an article is
# clicked through on the way to a target (excluding the start and target).
#
# Outputs:
#   output/tables/centrality.csv           every measure for every article
#   output/tables/centrality_top10.csv     top 10 articles per measure
#   output/tables/centrality_vs_usage.csv  Spearman correlation with waypoint usage
source(here::here("R/helpers.R"))
g     <- load_graph()
paths <- load_paths()

# ---- Centrality measures ----
ev  <- eigen_centrality(g, directed = TRUE)
lambda_max <- ev$value

katz_alpha <- 0.85 / lambda_max

hits <- hits_scores(g)

cent <- data.table(
  article     = V(g)$name,
  title       = V(g)$title,
  topic       = V(g)$topic,
  in_degree   = degree(g, mode = "in"),
  out_degree  = degree(g, mode = "out"),
  pagerank    = page_rank(g)$vector,
  hub         = hits$hub,
  authority   = hits$authority,
  eigenvector = ev$vector,
  katz        = alpha_centrality(g, alpha = katz_alpha, exo = 1),
  betweenness = betweenness(g, directed = TRUE),
  closeness_out = harmonic_centrality(g, mode = "out", normalized = TRUE),
  closeness_in  = harmonic_centrality(g, mode = "in",  normalized = TRUE)
)
measures <- setdiff(names(cent), c("article", "title", "topic"))

# ---- Waypoint usage from human games ----
# Count each article's appearances between start and target in finished games.
# Back-clicks ("<") are dropped.
fin <- paths[finished == TRUE]
waypoints <- unlist(lapply(fin$steps, function(s) {
  s <- s[s != "<"]
  if (length(s) > 2) s[2:(length(s) - 1)] else character(0)
}))
usage <- data.table(article = waypoints)[, .(usage = .N), by = article]
cent <- merge(cent, usage, by = "article", all.x = TRUE)
cent[is.na(usage), usage := 0L]

fwrite(cent[order(-usage)], table_path("centrality.csv"))

# ---- Top 10 per measure ----
top10 <- rbindlist(lapply(c(measures, "usage"), function(m) {
  cent[order(-get(m))][1:10, .(measure = m, rank = 1:10, title, value = get(m))]
}))
fwrite(top10, table_path("centrality_top10.csv"))

# ---- Which measure best predicts waypoint usage? ----
# Spearman correlation with usage, plus how many of each measure's
# top 50 are also in the top 50 most-used waypoints.
top_usage <- cent[order(-usage)][1:50, article]
compare <- rbindlist(lapply(measures, function(m) data.table(
  measure       = m,
  spearman      = cor(cent[[m]], cent$usage, method = "spearman"),
  top50_overlap = length(intersect(cent[order(-get(m))][1:50, article], top_usage))
)))[order(-spearman)]
fwrite(compare, table_path("centrality_vs_usage.csv"))
print(compare)

# TODO: does routing through top hubs shorten paths? (compare path
# length for games that pass through a top-k hub vs. games that don't)
