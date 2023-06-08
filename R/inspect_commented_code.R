
rleid <- function(x) {
  x <- rle(x)$lengths
  rep(seq_along(x), times = x)
}

inspect_commented_code <- function() {
  files <- list.files(here::here(), all.files = TRUE, full.names = TRUE, recursive = TRUE)
  files <- grep("\\.r$", files, ignore.case = TRUE, value = TRUE)

  inspect_block <- function(block) {
    n <- nrow(block)
    for (start in 1:n) {
      not_a_good_start_comment <-
        grepl("^ *$", block$code[start]) ||
        grepl(":$", block$code[start]) ||
        grepl(": ", block$code[start]) # or would yield false positive
      if (not_a_good_start_comment) next
      for (end in start:n)
        code <- block$code[start:end]
      parsed_lgl <- tryCatch(!is.symbol(parse(text = code)[[1]]), error = function(e) FALSE)
      if (parsed_lgl) {
        # keep only first line of commented code
        return(block[start, ])
      }
    }
    return(NULL)
  }

  inspect_blocks <- function(file) {
    code <- readLines(file)
    line <- seq_along(code)

    commented_lgl <- startsWith(code, "#") & !startsWith(code, "#'")
    block_id <- rleid(commented_lgl)
    blocks_df <- data.frame(line, message = code, code = sub("^#+", "", code), block_id)[commented_lgl, ]
    blocks <- split(blocks_df, blocks_df$block_id)

    df <- do.call(rbind, lapply(blocks, inspect_block))
    if (is.null(df)) return(df)
    df$block_id <- NULL
    df$code <- NULL
    df$file = file
    df
  }

  commented_code_df <- do.call(rbind, lapply(files, inspect_blocks))
  commented_code_df <- transform(commented_code_df, type = "info", column = 1)
  rstudioapi::sourceMarkers("commented code", commented_code_df)
}
