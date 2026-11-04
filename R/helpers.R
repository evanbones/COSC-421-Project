# Shared helpers. Every script starts with: source(here::here("R/helpers.R"))

suppressPackageStartupMessages({
  library(igraph)
  library(data.table)
  library(here)
  library(ggplot2)
})

raw_path       <- function(...) here("data", "raw", ...)
processed_path <- function(...) here("data", "processed", ...)
figure_path    <- function(...) here("output", "figures", ...)
table_path     <- function(...) here("output", "tables", ...)
wsp_dir        <- function(...) raw_path("wikispeedia_paths-and-graph", ...)

# Read a Wikispeedia TSV, skipping comment lines and blank lines
read_wsp <- function(file, col_names) {
  lines <- readLines(wsp_dir(file), encoding = "UTF-8")
  lines <- lines[!startsWith(lines, "#") & nzchar(lines)]
  fread(text = lines, sep = "\t", header = FALSE, col.names = col_names,
        quote = "", na.strings = "NULL")
}

# Article names are URL-encoded (e.g. "%C3%85land")
decode_title <- function(x) vapply(x, URLdecode, character(1), USE.NAMES = FALSE)

# Built by 01_build_graph.R
load_graph <- function() readRDS(processed_path("graph.rds"))
load_paths <- function() readRDS(processed_path("paths.rds"))
