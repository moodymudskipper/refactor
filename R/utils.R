gfn <- getFromNamespace
promise_code <- gfn("promise_code", "pryr")
promise_env <- gfn("promise_env", "pryr")
promise_evaled <- gfn("promise_evaled", "pryr")
is_promise2 <- gfn("is_promise2", "pryr")

clone_env <- function(env, deep = FALSE) {
  # create new environment with same parent
  clone <- new.env(parent = parent.env(env))
  for(obj in ls(env, all.names = TRUE)) {
    promise_lgl <- is_unevaled_promise(as.symbol(obj), env = env)
    if(promise_lgl) {
      # fetch promise expression and env
      promise_expr <- promise_code(obj, env)
      promise_env  <- promise_env(obj, env)

      # Assign this expression as a promise (delayed assignment) in our
      # cloned environment
      eval(bquote(
        delayedAssign(obj, .(promise_expr), eval.env = promise_env, assign.env = clone)))
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
  is_promise2(name, env) && !promise_evaled(name, env)
}

identical2 <- function(target, current, ...) {
  isTRUE(all.equal(target, current, ...))
}
