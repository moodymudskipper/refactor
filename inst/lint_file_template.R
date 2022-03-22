library(lintr)

path <- ""

#### spot signs of non robust code ---------------------------------------------

# Check that no absolute paths are used (e.g. "/var", "C:\System", "~/docs").
lint(path, linters = absolute_path_linter())

# checks that closures have the proper usage using checkUsage. Note this runs eval on the code, so do not use with untrusted code.
lint(path, linters = object_usage_linter)

# Avoid the symbols T and F (for TRUE and FALSE).
lint(path, linters = T_and_F_symbol_linter)

# check for 1:length(...), 1:nrow(...), 1:ncol(...), 1:NROW(...) and 1:NCOL(...) expressions.
# These often cause bugs when the right hand side is zero. It is safer to use seq_len or seq_along instead.
lint(path, linters = seq_linter)

# that checks for x == NA
lint(path, linters = equals_na_linter)

# Report the use of undesirable functions
# library() and source() are not recommended in a package but here we relax the
# behavior
undesirable <- default_undesirable_functions
undesirable$library <- NULL
undesirable$source <- NULL
lint(path, linters = undesirable_function_linter(undesirable))

# Check for overly complicated expressions. See ?lintr::cyclocomp
lint(path, linters = cyclocomp_linter(25))

# Check that each step in a pipeline is on a new line, or the entire pipe fits on one line.
lint(path, linters = pipe_continuation_linter)

# Report the use of undesirable operators, e.g. `:::` or `<<-` and suggest an alternative.
lint(path, linters = undesirable_operator_linter)

# Check that there is no commented code outside roxygen blocks
lint(path, linters = commented_code_linter)

# Check that the source contains no TODO or FIXME comments (case-insensitive).
lint(path, linters = todo_comment_linter("todo"))
lint(path, linters = todo_comment_linter("fixme"))

#### object names --------------------------------------------------------------

# Check that object names conform to a naming style.
lint(path, linters = object_name_linter(styles = "snake_case"))

# check that object names are not too long.
lint(path, linters = object_length_linter(length = 30))

#### pure style ----------------------------------------------------------------

# assignment_linter: checks that '<-' is always used for assignment
lint(path, linters = assignment_linter)

# Check that the c function is not used without arguments nor with a single constant.
lint(path, linters = unneeded_concatenation_linter)

# check that all commas are followed by spaces, but do not have spaces before them.
lint(path, linters = commas_linter)

# check that all infix operators have spaces around them.
lint(path, linters = infix_spaces_linter)

# check that only spaces are used for indentation, not tabs.
lint(path, linters = no_tab_linter)

# check the line length of both comments and code is less than length.
lint(path, linters = line_length_linter(80))

# check that opening curly braces are never on their own line and are always followed by a newline.
lint(path, linters = open_curly_linter(allow_single_line = FALSE))

# check that closed curly braces should always be on their own line unless they follow an else.
lint(path, linters = closed_curly_linter(allow_single_line = FALSE))

# check that all left parentheses have a space before them unless they are in a function call.
lint(path, linters = spaces_left_parentheses_linter)

# check that all left parentheses in a function call do not have spaces before them.
lint(path, linters = function_left_parentheses_linter)

# check that there is a space between right parenthesis and an opening curly brace.
lint(path, linters = paren_brace_linter)

# check that parentheses and square brackets do not have spaces directly inside them.
lint(path, linters = spaces_inside_linter)

# Check that no semicolons terminate statements.
lint(path, linters = semicolon_terminator_linter)

# checks that only single quotes are used to delimit string constants.
lint(path, linters = single_quotes_linter)

# check there are no trailing blank lines.
lint(path, linters = trailing_blank_lines_linter)

# check there are no trailing whitespace characters.
lint(path, linters = trailing_whitespace_linter)

#### Zealous linters -----------------------------------------------------------
# These are not very important or yield a lot of false positives

# Check that the '[[' operator is used when extracting a single element from an object, not '[' (subsetting) nor '$' (interactive use).
lint(path, linters = extraction_operator_linter)

# Check that integers are explicitly typed using the form 1L instead of 1.
lint(path, linters = implicit_integer_linter)

# Check that file.path() is used to construct safe and portable paths.
lint(path, linters = nonportable_path_linter())
