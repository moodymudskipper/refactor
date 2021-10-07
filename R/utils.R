clone_env <- function(env, deep = FALSE) {
  # create new environment with same parent
  clone <- new.env(parent = parent.env(env))
  for(obj in ls(env, all.names = TRUE)) {
    promise_lgl <- is_unevaled_promise(as.symbol(obj), env = env)
    if(promise_lgl) {
      # fetch promise expression, we use bquote to feed the right unquoted
      # value to substitute
      promise_expr <- eval(bquote(substitute(.(as.symbol(obj)), env = env)))
      # Assign this expression as a promise (delayed assignment) in our
      # cloned environment
      eval(bquote(
        delayedAssign(obj, .(promise_expr), eval.env = env, assign.env = clone)))
    } else {
      obj_val <- get(obj, envir = env)
      if(is.environment(obj_val) && deep) {
        assign(obj, clone_env(obj_val, deep = TRUE),envir= clone)
      } else  {
        assign(obj, obj_val, envir= clone)
      }
    }
  }
  attributes(clone) <- attributes(env)
  clone
}

is_unevaled_promise <- function(name, env) {
  pryr:::is_promise2(name, env) && !pryr:::promise_evaled(name, env)
}

identical2 <- function(target, current, ...) {
  isTRUE(all.equal(target, current, ...))
}
