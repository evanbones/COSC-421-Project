# Run once to install everything the project needs.
pkgs <- c(
  "igraph",      # graph construction + all network metrics
  "data.table",  # fast reading/filtering of large edge lists
  "here",        # project-relative paths
  "ggplot2",     # figures
  "rmarkdown"    # report
)
install.packages(setdiff(pkgs, rownames(installed.packages())),
                 repos = "https://cloud.r-project.org")
