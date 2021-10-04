refactor_impl <- function(original, refactored, refactor.value, refactor.time, refactor.env, refactor.waldo, pf) {

  ## record env before modifications
  original_env_as_list  <- clone_env(pf)
  original_var_nms  <- names(original_env_as_list)


  if(refactor.time) {
    original_time     <- system.time(original_value   <- eval(original, pf))[["elapsed"]]
  } else {
    original_value   <- eval(original, pf)
  }

  ## record env after modifications made by original code
  new_env1_as_list   <- clone_env(pf)
  new_var_nms       <- names(new_env1_as_list)

  ## reinitiate env
  rm(list=setdiff(new_var_nms, original_var_nms), envir = pf)
  for (var_nm in intersect(new_var_nms, original_var_nms)) {
    promise_lgl <- pryr:::is_promise2(as.symbol(var_nm), env = pf)
    if(promise_lgl) {
      promise_expr <- pryr:::promise_code(var_nm, pf)
      promise_env <- pryr:::promise_env(var_nm, pf)
      # Assign this expression as a promise (delayed assignment) in our
      # cloned environment
      eval(bquote(
        delayedAssign(var_nm, .(promise_expr), eval.env = promise_env, assign.env = pf)))
    } else {
      pf[[var_nm]] <- original_env_as_list[[var_nm]]
    }
  }

  if(refactor.time) {
    refactored_time   <- system.time(refactored_value <- eval(refactored, pf))[["elapsed"]]
  } else {
    refactored_value <- eval(refactored, pf)
  }

  ## record env after modifications made by refactored code
  new_env2_as_list   <- clone_env(pf)

  if(refactor.value && !identical(original_value, refactored_value)) {
    stop("The refactored expression returns a different value than the original one.\n\n",
         if(refactor.waldo)
           paste(waldo::compare(
             original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
             collapse = "\n\n")
         else
           paste(all.equal(original_value, refactored_value), collapse = "\n\n"),
         call. = FALSE)
  }

  if(refactor.env) {
    vars1 <- ls(envir = new_env1_as_list, all.names = TRUE)
    vars2 <- ls(envir = new_env2_as_list, all.names = TRUE)
    if(!identical(vars1, vars2)) {
      setdiff1 <- setdiff(vars1, vars2)
      msg1 <- paste0(
        "Some variables defined in the original code, were not found in the ",
        "refactored code: ", toString(setdiff1),
        "\nDo you need `rm(", toString(setdiff1), ")`")
      setdiff2 <- setdiff(vars2, vars1)
      msg2 <- paste0(
        "Some variables defined in the refactored code, were not found in the ",
        "original code: ", toString(setdiff1),
        "\nDo you need `rm(", toString(setdiff2), ")`")
      stop(paste(c(msg1, msg2), collapse = "\n"), call. = FALSE)
    }
    for(var_nm in vars1) {
      promise_lgl <- pryr:::is_promise2(as.symbol(var_nm), env = new_env1_as_list)
      if(promise_lgl) {
        if(! pryr:::is_promise2(var_nm, new_env2_as_list))
          stop("`", var_nm, "` is a promise in the original code, but is evaluated",
               "in the refactored code")

        promise_info1 <- list(
          code = pryr:::promise_code(var_nm, new_env1_as_list),
          env = pryr:::promise_env(var_nm, new_env1_as_list))

        promise_info2 <- list(
          code = pryr:::promise_code(var_nm, new_env2_as_list),
          env = pryr:::promise_env(var_nm, new_env2_as_list))

        if(!identical(promise_info1, promise_info2)) {
          stop("The promise `var_nm` is different in original and refactored code \n",
               paste(waldo::compare(
                 promise_info1, promise_info2, x_arg = "original", y_arg = "refactored"),
                 collapse = "\n\n"),
               call. = FALSE)
        }
      } else {
        if(pryr:::is_promise2(var_nm, new_env2_as_list))
          stop("`", var_nm, "` is a promise in the refactored code, but is evaluated",
               "in the original code")
        val1 <- new_env1_as_list[[var_nm]]
        val2 <- new_env2_as_list[[var_nm]]
        if(!identical(val1, val2)) {
          stop("The variable `", var_nm, "` is bound to a  different value ",
               "after the original and refactored code\n",
               if(refactor.waldo)
                 paste(waldo::compare(
                   val1, val2, x_arg = "original", y_arg = "refactored"),
                   collapse = "\n\n")
               else
                 paste(all.equal(val1, val2), collapse = "\n\n"),
               call. = FALSE)
        }

      }
    }
  }

  if(refactor.time && refactored_time > original_time) {
    stop("The refactored code ran slower than the original code.\n",
         paste(waldo::compare(
           original_time, refactored_time, x_arg = "original time (s)", y_arg = "refactored time (s)"),
           collapse = "\n\n"),
         call. = FALSE)
  }
  return(original_value)
}
