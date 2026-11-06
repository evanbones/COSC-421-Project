# 04 - Q2: Terminal sinks and component boundaries
# Out-degree-0 articles, strong/weak components, k-cores / k-edge components.
source(here::here("R/helpers.R"))

g     <- load_graph()
paths <- load_paths()

# part 1: sinks
out_degree <- degree(g, mode = "out")
in_degree <- degree(g, mode = "in")
is_sink <- out_degree == 0
sink_names <- V(g)$name[is_sink]
print("Number of Sinks")
print(length(sink_names))
print("Names of Sinks")
print(sink_names)
print("In-degree of Sinks")
print(sort(in_degree[is_sink], decreasing = TRUE))

visited_sink <- logical(nrow(paths))

for (i in 1:nrow(paths)) {
  s <- paths$steps[[i]]
  
  if (paths$finished[i]) {
    s <- s[-length(s)]  # if finished drop the target as it is not unintentional
   }
  
  visited_sink[i] <- any(s %in% sink_names)
}

paths$visited_sink <- visited_sink

print(paths[, .(games = .N, proportion_visited = mean(visited_sink)), by = finished])
visited_sink_count <- (table(visited_sink = paths$visited_sink, finished = paths$finished))
fwrite(visited_sink_count, table_path("visited_sink_count.csv"))
print(visited_sink_count)
#part 2: K centrality

all_core <- coreness(g, mode = "all")
in_core  <- coreness(g, mode = "in")
out_core <- coreness(g, mode = "out")

print("Max cores")
print(c(max(all_core), max(in_core), max(out_core)))

print("Number of articles at each coreness (out_core)")
print(table(out_core))

max_k <- max(out_core)
top_core <- V(g)$name[out_core == max_k]

print("some names of articles at top core(out core)")
print(head(top_core, 30))

print("average coreness of an article (out core)")
print(mean(out_core))
