#' @docType package
#' @usage NULL
#' @useDynLib specprepper, .registration = TRUE
NULL

#' Return string `"Hello world!"` to R.
#' @export
hello_world <- function() .Call(wrap__hello_world)
