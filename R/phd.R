# Helpers for the thesis pages in phd/ (run from that folder)
source("../R/bib.R")

phd_data <- read.csv("../data/phd-supervision.csv", encoding = "UTF-8",
                     stringsAsFactors = FALSE)

# Key facts block at the top of a thesis page
phd_facts <- function(slug) {
  p <- phd_data[phd_data$slug == slug, ]
  cat("::: {.phd-facts}\n")
  cat("**PhD candidate:** ", p$student, "  \n", sep = "")
  cat("**Period:** ", p$period, "  \n", sep = "")
  cat("**Supervision:** Iragaël Joly, ", sub("^with ", "with ", p$co_supervision), "  \n", sep = "")
  cat("**Funding:** ", p$funding, "  \n", sep = "")
  cat("**Status:** ", p$outcome, "\n", sep = "")
  cat(":::\n\n")
}

# Publications co-authored with the PhD candidate
phd_publications <- function(surname) {
  e <- entries_by_author(surname)
  if (length(e) == 0) {
    cat("Publications will be listed here as they appear.\n")
  } else {
    cat("::: {.pubs}\n\n")
    print_entries(e)
    cat(":::\n")
  }
}
