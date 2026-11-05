# 02 - Baseline statistics
# Node/edge count, density, reciprocity, average in/out degree,
# degree distributions.
#
# Outputs:
#   output/tables/baseline_stats.csv
#   output/tables/top_degree.csv
#   output/figures/degree_distribution.png
source(here::here("R/helpers.R"))
g <- load_graph()

in_deg  <- degree(g, mode = "in")
out_deg <- degree(g, mode = "out")

# ---- Summary table ----
stats <- data.table(
  metric = c("nodes", "edges", "density", "reciprocity",
             "mean_degree", "median_in_degree", "median_out_degree",
             "max_in_degree", "max_out_degree",
             "sinks_out0", "sources_in0", "isolated"),
  value = c(vcount(g), ecount(g), edge_density(g), reciprocity(g),
            # mean in-degree == mean out-degree == edges / nodes
            mean(in_deg), median(in_deg), median(out_deg),
            max(in_deg), max(out_deg),
            sum(out_deg == 0), sum(in_deg == 0), sum(in_deg + out_deg == 0))
)
fwrite(stats, table_path("baseline_stats.csv"))
print(stats)

# ---- Highest-degree articles ----
deg <- data.table(article = V(g)$name, title = V(g)$title, topic = V(g)$topic,
                  in_degree = in_deg, out_degree = out_deg)
top_degree <- rbind(
  deg[order(-in_degree)][1:10][, rank_by := "in"],
  deg[order(-out_degree)][1:10][, rank_by := "out"]
)
fwrite(top_degree, table_path("top_degree.csv"))
print(top_degree[, .(rank_by, title, in_degree, out_degree)])

# ---- Degree distributions ----
ccdf <- function(x, direction) {
  x <- x[x > 0]  # log scale can't show zeros
  k <- sort(unique(x))
  data.table(k = k, p = vapply(k, function(v) mean(x >= v), numeric(1)),
             direction = direction)
}
dist <- rbind(ccdf(in_deg, "In-degree"), ccdf(out_deg, "Out-degree"))

p <- ggplot(dist, aes(k, p, colour = direction)) +
  geom_point(size = 1, alpha = 0.7) +
  scale_x_log10() + scale_y_log10() +
  labs(x = "Degree k", y = "P(degree >= k)", colour = NULL,
       title = "Degree distributions (CCDF)") +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave(figure_path("degree_distribution.png"), p, width = 6, height = 4.5, dpi = 300)
