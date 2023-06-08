refactor_impl <- function(original, refactored, refactor.value, refactor.time, refactor.env, refactor.waldo, src_env) {

  ## record env before modifications
  original_env  <- clone_env(src_env)
  original_var_nms  <- names(original_env)


  if(refactor.time) {
    original_time     <- system.time(original_value   <- eval(original, src_env))[["elapsed"]]
  } else {
    original_value   <- eval(original, src_env)
  }

  ## record env after modifications made by original code
  new_env1    <- clone_env(src_env)
  new_var_nms <- names(new_env1)

  ## reinitiate env
  rm(list=setdiff(new_var_nms, original_var_nms), envir = src_env)
  for (var_nm in intersect(new_var_nms, original_var_nms)) {
    promise_lgl <- is_unevaled_promise(var_nm, src_env)
    if(promise_lgl) {
      promise_expr <- pryr:::promise_code(var_nm, src_env)
      promise_env  <- pryr:::promise_env(var_nm, src_env)
      # Assign this expression as a promise (delayed assignment) in our
      # cloned environment
      eval(bquote(
        delayedAssign(var_nm, .(promise_expr), eval.env = promise_env, assign.env = src_env)))
    } else {
      src_env[[var_nm]] <- original_env[[var_nm]]
    }
  }

  if(refactor.time) {
    refactored_time   <- system.time(refactored_value <- eval(refactored, src_env))[["elapsed"]]
  } else {
    refactored_value <- eval(refactored, src_env)
  }

  ## record env after modifications made by refactored code
  new_env2   <- clone_env(src_env)

  if(refactor.value && !identical2(original_value, refactored_value)) {
    stop("The refactored expression returns a different value from the original one.\n\n",
         if(refactor.waldo)
           paste(waldo::compare(
             original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
             collapse = "\n\n")
         else
           paste(all.equal(original_value, refactored_value), collapse = "\n\n"),
         call. = FALSE)
  }

  if(refactor.env) {
    vars1 <- ls(envir = new_env1, all.names = TRUE)
    vars2 <- ls(envir = new_env2, all.names = TRUE)
    if(!identical2(vars1, vars2)) {
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
      promise_lgl <- is_unevaled_promise(var_nm, env = new_env1)
      if(promise_lgl) {
        if(! is_unevaled_promise(var_nm, new_env2))
          stop("`", var_nm, "` is an unevaled promise in the original code, but is evaluated",
               "in the refactored code")

        promise_info1 <- list(
          code = pryr:::promise_code(var_nm, new_env1),
          env = pryr:::promise_env(var_nm, new_env1))

        promise_info2 <- list(
          code = pryr:::promise_code(var_nm, new_env2),
          env = pryr:::promise_env(var_nm, new_env2))

        if(!identical(promise_info1, promise_info2)) {
          stop("The promise `var_nm` is different in original and refactored code \n",
               paste(waldo::compare(
                 promise_info1, promise_info2, x_arg = "original", y_arg = "refactored"),
                 collapse = "\n\n"),
               call. = FALSE)
        }
      } else {
        if(is_unevaled_promise(var_nm, new_env2))
          stop("`", var_nm, "` is an unevaled promise in the refactored code, but is evaluated",
               "in the original code")
        val1 <- new_env1[[var_nm]]
        val2 <- new_env2[[var_nm]]
        if(!identical2(val1, val2)) {
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
