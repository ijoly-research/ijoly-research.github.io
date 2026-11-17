# Lightweight BibTeX reader and formatter for the website.
# Base R only, so the site builds anywhere without extra packages.
#
# Main functions:
#   read_bib(path)            -> list of entries (each a named list of fields)
#   format_entry(entry)       -> one formatted reference (Markdown)
#   print_bib_section(path)   -> prints a numbered list (use with results='asis')

# ---- Settings -----------------------------------------------------------------

# Name shown in bold in author lists
me <- "Joly"

# PhD students supervised: shown underlined in author lists
students <- c("Gusarov", "Dang", "Kouyoumji", "Hernandez Marquina",
              "Wang", "Bouscasse", "Duarte Ferrin")

# ---- Parsing --------------------------------------------------------------------

latex_to_text <- function(x) {
  if (is.null(x) || is.na(x)) return(x)
  accents <- list(
    "'" = c(a = "\u00e1", e = "\u00e9", i = "\u00ed", o = "\u00f3", u = "\u00fa", E = "\u00c9", y = "\u00fd"),
    "`" = c(a = "\u00e0", e = "\u00e8", i = "\u00ec", o = "\u00f2", u = "\u00f9", E = "\u00c8", A = "\u00c0"),
    "^" = c(a = "\u00e2", e = "\u00ea", i = "\u00ee", o = "\u00f4", u = "\u00fb"),
    "\"" = c(a = "\u00e4", e = "\u00eb", i = "\u00ef", o = "\u00f6", u = "\u00fc"),
    "c" = c(c = "\u00e7", C = "\u00c7")
  )
  for (cmd in names(accents)) {
    for (l in names(accents[[cmd]])) {
      rep <- accents[[cmd]][[l]]
      esc <- if (cmd == "c") "c\\s*" else paste0("\\", cmd)
      pats <- c(
        paste0("\\{\\\\", esc, "\\{", l, "\\}\\}"),   # {\'{e}}
        paste0("\\{\\\\", esc, l, "\\}"),             # {\'e}
        paste0("\\\\", esc, "\\{", l, "\\}"),         # \'{e}
        if (cmd == "c") paste0("\\\\c\\s+", l) else paste0("\\\\", esc, l)  # \'e
      )
      for (p in pats) x <- gsub(p, rep, x, perl = TRUE)
    }
  }
  x <- gsub("``", "\u201c", x, fixed = TRUE)
  x <- gsub("''", "\u201d", x, fixed = TRUE)
  x <- gsub("\\&", "&", x, fixed = TRUE)
  x <- gsub("---", "\u2014", x, fixed = TRUE)
  x <- gsub("--", "\u2013", x, fixed = TRUE)
  x <- gsub("~", "\u00a0", x, fixed = TRUE)
  x <- gsub("\\\\(textit|emph|textbf)\\{([^{}]*)\\}", "\\2", x, perl = TRUE)
  x <- gsub("[{}]", "", x)
  x <- gsub("^\\s*\"|\"\\s*$", "", x)   # value wrapped in quotes inside braces
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

# Reads the value starting at position i of string s; returns list(value, next_i)
read_value <- function(s, i) {
  ch <- substr(s, i, i)
  if (ch == "{") {
    depth <- 0; j <- i
    repeat {
      c2 <- substr(s, j, j)
      if (c2 == "{") depth <- depth + 1
      if (c2 == "}") { depth <- depth - 1; if (depth == 0) break }
      j <- j + 1
      if (j > nchar(s)) break
    }
    list(value = substr(s, i + 1, j - 1), next_i = j + 1)
  } else if (ch == "\"") {
    j <- i + 1
    while (j <= nchar(s) && substr(s, j, j) != "\"") j <- j + 1
    list(value = substr(s, i + 1, j - 1), next_i = j + 1)
  } else {
    m <- regexpr("^[^,}\\s]+", substr(s, i, nchar(s)), perl = TRUE)
    len <- attr(m, "match.length")
    list(value = substr(s, i, i + len - 1), next_i = i + len)
  }
}

parse_entry_body <- function(body) {
  # body = "key, field = value, ..."
  key_end <- regexpr(",", body, fixed = TRUE)
  key <- trimws(substr(body, 1, key_end - 1))
  s <- substr(body, key_end + 1, nchar(body))
  fields <- list()
  i <- 1
  n <- nchar(s)
  while (i <= n) {
    rest <- substr(s, i, n)
    m <- regexpr("^[\\s,]*([A-Za-z_+-]+)\\s*=\\s*", rest, perl = TRUE)
    if (m == -1) break
    name <- tolower(sub("^[\\s,]*([A-Za-z_+-]+)\\s*=\\s*$", "\\1",
                        regmatches(rest, m), perl = TRUE))
    i <- i + attr(m, "match.length")
    v <- read_value(s, i)
    fields[[name]] <- latex_to_text(v$value)
    i <- v$next_i
  }
  list(key = key, fields = fields)
}

read_bib <- function(path) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  lines <- lines[!grepl("^\\s*%", lines)]          # drop comment lines
  s <- paste(lines, collapse = "\n")
  entries <- list()
  pos <- 1
  repeat {
    m <- regexpr("@([A-Za-z]+)\\s*\\{", substr(s, pos, nchar(s)), perl = TRUE)
    if (m == -1) break
    start <- pos + m - 1
    type <- tolower(sub("@([A-Za-z]+).*", "\\1", regmatches(substr(s, pos, nchar(s)), m)))
    open <- start + attr(m, "match.length") - 1
    depth <- 0; j <- open
    repeat {
      ch <- substr(s, j, j)
      if (ch == "{") depth <- depth + 1
      if (ch == "}") { depth <- depth - 1; if (depth == 0) break }
      j <- j + 1
      if (j > nchar(s)) break
    }
    e <- parse_entry_body(substr(s, open + 1, j - 1))
    e$type <- type
    entries[[length(entries) + 1]] <- e
    pos <- j + 1
  }
  # drop duplicated keys within a file (keep the first, most complete one)
  keys <- vapply(entries, `[[`, "", "key")
  entries[!duplicated(keys)]
}

# ---- Formatting -----------------------------------------------------------------

format_authors <- function(authors) {
  if (is.null(authors) || is.na(authors)) return("")
  parts <- trimws(strsplit(authors, "\\s+and\\s+")[[1]])
  out <- vapply(parts, function(a) {
    nm <- if (grepl(",", a)) {
      p <- trimws(strsplit(a, ",")[[1]])
      paste(p[1], paste(p[-1], collapse = " "))
    } else a
    last <- if (grepl(",", a)) trimws(strsplit(a, ",")[[1]][1]) else a
    if (last == me) return(paste0("**", nm, "**"))
    if (last %in% students) return(paste0("[", nm, "]{.student}"))
    nm
  }, "")
  paste(out, collapse = ", ")
}

plain_names <- function(x) {
  parts <- trimws(strsplit(x, "\\s+and\\s+")[[1]])
  paste(vapply(parts, function(a) {
    if (!grepl(",", a)) return(a)
    p <- trimws(strsplit(a, ",")[[1]])
    paste(p[1], paste(p[-1], collapse = " "))
  }, ""), collapse = ", ")
}

f <- function(e, name) {
  v <- e$fields[[name]]
  if (is.null(v) || is.na(v) || !nzchar(v)) NULL else v
}

join <- function(...) {
  x <- unlist(list(...))
  x <- x[!is.null(x) & nzchar(x)]
  paste(x, collapse = ", ")
}

hal_link <- function(note) {
  if (is.null(note)) return(NULL)
  id <- regmatches(note, regexpr("(hal|halshs)-[0-9]+", note))
  if (length(id) == 0) return(NULL)
  paste0("[HAL](https://hal.science/", id, ")")
}

format_entry <- function(e) {
  authors <- format_authors(f(e, "author"))
  year <- f(e, "year")
  title <- f(e, "title")
  if (!is.null(f(e, "subtitle"))) title <- paste0(title, ": ", f(e, "subtitle"))
  pages <- if (!is.null(f(e, "pages"))) paste0("pp. ", f(e, "pages"))
  note <- f(e, "note")
  note_txt <- if (!is.null(note) && !grepl("^(HAL:|hal|halshs)", note)) note

  where <- switch(e$type,
    article = {
      vol <- f(e, "volume"); num <- f(e, "number")
      vn <- if (!is.null(vol) && !is.null(num)) paste0(vol, "(", num, ")") else join(vol, num)
      join(paste0("*", f(e, "journal"), "*"), vn, pages, note_txt)
    },
    inproceedings = join(paste0("*", f(e, "booktitle"), "*"), f(e, "address"), pages, note_txt),
    incollection = {
      ed <- f(e, "editor")
      ed <- if (!is.null(ed)) paste0("ed. by ", plain_names(ed))
      join(paste0("In *", f(e, "booktitle"), "*"), ed, f(e, "publisher"), f(e, "address"), pages)
    },
    book = join(f(e, "publisher"), f(e, "address"), if (!is.null(f(e, "pages"))) paste0(f(e, "pages"), " p.")),
    report = join(f(e, "institution"), f(e, "type"), pages, note_txt),
    online = join(f(e, "organization"), note_txt),
    join(f(e, "journal"), f(e, "booktitle"), note_txt)
  )
  # placeholder "*NA*" if a field is missing
  where <- gsub("\\*NULL\\*|In \\*\\*", "", where)

  title_fmt <- if (e$type == "book") paste0("*", title, "*") else title
  links <- c(
    if (!is.null(f(e, "doi"))) paste0("[DOI](https://doi.org/", f(e, "doi"), ")"),
    hal_link(note),
    if (!is.null(f(e, "url"))) paste0("[Link](", f(e, "url"), ")")
  )
  sep <- if (grepl("[?!]\\*?$", title_fmt)) " " else ". "
  ref <- paste0(authors, " (", year, "). ", title_fmt, sep, where)
  ref <- sub("[.,]\\s*$", "", ref)
  ref <- paste0(ref, ".")
  if (length(links)) ref <- paste0(ref, " ", paste(links, collapse = " · "))
  ref
}

sort_entries <- function(entries) {
  yrs <- suppressWarnings(as.integer(vapply(entries, function(e) {
    y <- f(e, "year"); if (is.null(y)) NA_character_ else y
  }, "")))
  entries[order(-yrs, seq_along(entries), na.last = TRUE)]
}

# Prints a section as a numbered Markdown list
print_bib_section <- function(path) {
  entries <- sort_entries(read_bib(path))
  for (e in entries) cat("1. ", format_entry(e), "\n", sep = "")
  cat("\n")
}

count_bib <- function(path) length(read_bib(path))

# Most recent items across several files (for the home page)
recent_items <- function(paths, n = 5) {
  all <- unlist(lapply(paths, read_bib), recursive = FALSE)
  all <- sort_entries(all)
  head(all, n)
}
