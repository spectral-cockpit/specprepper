#' @import data.table
#' @importFrom future.apply future_lapply future_Map
if (getRversion() >= "2.15.1") utils::globalVariables(c(":="))

# global reference to zarr (will be initialized in .onLoad)
zarr <- NULL

.onLoad <- function(libname, pkgname) {
  # use superassignment to update global reference to scipy
  scipy <<- reticulate::import("zarr", delay_load = TRUE)
}
