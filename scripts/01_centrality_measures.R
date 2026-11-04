source(here::here("R/helpers.R"))

#create the graph object using our data
wsp <- read_wsp("articles.tsv")
links <- read_wsp("links.tsv")
graph <- graph_from_data_frame(links, directed = TRUE)

#basic graph info
vcount(graph)
ecount(graph)
edge_density(graph)
mean(degree(graph, mode = "in"))

#eigen centrality leaders
eg <- eigen_centrality(graph, directed = TRUE)
eigen <- sort(eg$vector, decreasing = TRUE)
eigen[1:10]

#katz centrality leaders
kt <- alpha_centrality(graph, alpha = 0.1, exo = 1)
katz <- sort(kt, decreasing = TRUE)
katz[1:10]

#PageRank centrality leaders
pg <- page_rank(graph)
page <- sort(pg$vector, decreasing = TRUE)
page[1:10]

#degree leaders
in_deg <- degree(graph, mode = "in")
out_deg <- degree(graph, mode = "out")
in_degree <-sort(in_deg, decreasing = TRUE)
out_degree <- sort(out_deg, decreasing = TRUE)

in_degree[1:10]
out_degree[1:10]

#betweeness leaders
bt <- betweenness(graph, directed = TRUE)
betweeness <- sort(bt, decreasing = TRUE)
betweeness[1:10]
