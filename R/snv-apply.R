#' @param X `matrix`, `data.frame` or `data.table` with spectra used as input
#' to compute standard normal variate (SNV)
#' @inheritParams sg_apply
#' @export
snv_apply <- function(X,
                      dt_prep_sets,
                      append_rows = FALSE) {
  if (!missing(X)) {
    stopifnot(
      "`X` needs to be data frame (including data.table) or matrix" =
        is.matrix(X) || is.data.frame(X)
    )
  }

  if (!is.null(dt_prep_sets)) {
    checkset_dt_prep_sets(dt_prep_sets)
  }

  if (is.null(dt_prep_sets)) {
    spc_list <- list(X)
  } else {
    spc_list <- dt_prep_sets$spc_prep
  }
}

# nolint start
snv_impl_base <- function(X) {
  X <- sweep(as.matrix(X), 1L, rowMeans(as.matrix(X), na.rm = TRUE), `-`)
  X_sc <- sweep(X, 1L, apply(X, 1, sd, na.rm = TRUE), `/`)
  return(X_sc)
}

checkset_dt_prep_sets <- function(dt_prep_sets) {
  stopifnot(
    "`dt_prep_sets` needs to be data frame (can be data.table)" =
      is.data.frame(dt_prep_sets)
  )

  if (!"spc_prep" %in% colnames(dt_prep_sets)) {
    stop(strwrap(
      "`data.table` `dt_prep_sets` requires the column named `spc_prep`,
         which contains a list of already processed spectra",
      prefix = "\n"
    ))
  }
  if (!is.data.table(dt_prep_sets)) setDT(dt_prep_sets)
}
