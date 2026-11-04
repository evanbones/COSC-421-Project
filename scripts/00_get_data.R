# 00 - Get data
# Downloads the Wikispeedia dataset (West & Leskovec, SNAP) into data/raw/.
#   https://snap.stanford.edu/data/wikispeedia.html
#
# Contents of wikispeedia_paths-and-graph/:
#   articles.tsv                       4,604 article names (URL-encoded)
#   links.tsv                          directed hyperlinks: source \t target
#   categories.tsv                     article \t category (e.g. subject.Science.Biology)
#   paths_finished.tsv                 human games that reached the target
#   paths_unfinished.tsv               human games that were abandoned
#   shortest-path-distance-matrix.txt  precomputed all-pairs shortest paths
source(here::here("R/helpers.R"))

url     <- "https://snap.stanford.edu/data/wikispeedia/wikispeedia_paths-and-graph.tar.gz"
archive <- raw_path(basename(url))

if (!dir.exists(wsp_dir())) {
  options(timeout = max(600, getOption("timeout")))
  download.file(url, archive, mode = "wb")
  untar(archive, exdir = raw_path())
  unlink(archive)
}

stopifnot(file.exists(wsp_dir("links.tsv")))
message("Wikispeedia data ready in ", wsp_dir())
