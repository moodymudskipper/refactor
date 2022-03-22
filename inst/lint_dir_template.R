library(lintr)

linted_dir <- here::here()

#### spot signs of non robust code ---------------------------------------------

# Check that no absolute paths are used (e.g. "/var", "C:\System", "~/docs").
lint_dir(linted_dir, linters = absolute_path_linter())

# checks that closures have the proper usage using checkUsage. Note this runs eval on the code, so do not use with untrusted code.
lint_dir(linted_dir, linters = object_usage_linter)

# Avoid the symbols T and F (for TRUE and FALSE).
lint_dir(linted_dir, linters = T_and_F_symbol_linter)

# check for 1:length(...), 1:nrow(...), 1:ncol(...), 1:NROW(...) and 1:NCOL(...) expressions.
# These often cause bugs when the right hand side is zero. It is safer to use seq_len or seq_along instead.
lint_dir(linted_dir, linters = seq_linter)

# that checks for x == NA
lint_dir(linted_dir, linters = equals_na_linter)

# Report the use of undesirable functions
# library() and source() are not recommended in a package but here we relax the
# behavior
undesirable <- default_undesirable_functions
undesirable$library <- NULL
undesirable$source <- NULL
lint_dir(linted_dir, linters = undesirable_function_linter(undesirable))

# Check for overly complicated expressions. See ?lintr::cyclocomp
lint_dir(linted_dir, linters = cyclocomp_linter(25))

# Check that each step in a pipeline is on a new line, or the entire pipe fits on one line.
lint_dir(linted_dir, linters = pipe_continuation_linter)

# Report the use of undesirable operators, e.g. `:::` or `<<-` and suggest an alternative.
lint_dir(linted_dir, linters = undesirable_operator_linter)

# Check that there is no commented code outside roxygen blocks
lint_dir(linted_dir, linters = commented_code_linter)

# Check that the source contains no TODO or FIXME comments (case-insensitive).
lint_dir(linted_dir, linters = todo_comment_linter("todo"))
lint_dir(linted_dir, linters = todo_comment_linter("fixme"))

#### object names --------------------------------------------------------------

# Check that object names conform to a naming style.
lint_dir(linted_dir, linters = object_name_linter(styles = "snake_case"))

# check that object names are not too long.
lint_dir(linted_dir, linters = object_length_linter(length = 30))

#### pure style ----------------------------------------------------------------

# assignment_linter: checks that '<-' is always used for assignment
lint_dir(linted_dir, linters = assignment_linter)

# Check that the c function is not used without arguments nor with a single constant.
lint_dir(linted_dir, linters = unneeded_concatenation_linter)

# check that all commas are followed by spaces, but do not have spaces before them.
lint_dir(linted_dir, linters = commas_linter)

# check that all infix operators have spaces around them.
lint_dir(linted_dir, linters = infix_spaces_linter)

# check that only spaces are used for indentation, not tabs.
lint_dir(linted_dir, linters = no_tab_linter)

# check the line length of both comments and code is less than length.
lint_dir(linted_dir, linters = line_length_linter(80))

# check that opening curly braces are never on their own line and are always followed by a newline.
lint_dir(linted_dir, linters = open_curly_linter(allow_single_line = FALSE))

# check that closed curly braces should always be on their own line unless they follow an else.
lint_dir(linted_dir, linters = closed_curly_linter(allow_single_line = FALSE))

# check that all left parentheses have a space before them unless they are in a function call.
lint_dir(linted_dir, linters = spaces_left_parentheses_linter)

# check that all left parentheses in a function call do not have spaces before them.
lint_dir(linted_dir, linters = function_left_parentheses_linter)

# check that there is a space between right parenthesis and an opening curly brace.
lint_dir(linted_dir, linters = paren_brace_linter)

# check that parentheses and square brackets do not have spaces directly inside them.
lint_dir(linted_dir, linters = spaces_inside_linter)

# Check that no semicolons terminate statements.
lint_dir(linted_dir, linters = semicolon_terminator_linter)

# checks that only single quotes are used to delimit string constants.
lint_dir(linted_dir, linters = single_quotes_linter)

# check there are no trailing blank lines.
lint_dir(linted_dir, linters = trailing_blank_lines_linter)

# check there are no trailing whitespace characters.
lint_dir(linted_dir, linters = trailing_whitespace_linter)

#### Zealous linters -----------------------------------------------------------
# These are not very important or yield a lot of false positives

# Check that the '[[' operator is used when extracting a single element from an object, not '[' (subsetting) nor '$' (interactive use).
lint_dir(linted_dir, linters = extraction_operator_linter)

# Check that integers are explicitly typed using the form 1L instead of 1.
lint_dir(linted_dir, linters = implicit_integer_linter)

# Check that file.path() is used to construct safe and portable paths.
lint_dir(linted_dir, linters = nonportable_path_linter())
