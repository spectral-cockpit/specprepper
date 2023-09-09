#' Compute the standard normal variate for collections of spectra
#' @param X `matrix`, `data.frame` or `data.table` with spectra used as input
#' to compute standard normal variate (SNV)
#' @inheritParams sg_apply
#' @export
snv_apply <- function(X,
                      dt_prep_sets = NULL,
                      append_rows = FALSE) {
  if (!missing(X)) {
    stopifnot(
      "`X` needs to be data frame (including data.table) or matrix" =
        is.matrix(X) || is.data.frame(X)
    )
  }

  prep_label <- prep_params <- prep_set <- spc_prep <- NULL

  if (!is.null(dt_prep_sets)) {
    checkset_dt_prep_sets(dt_prep_sets)
  }

  if (is.null(dt_prep_sets)) {
    spc_list <- list(X)
  } else {
    spc_list <- dt_prep_sets$spc_prep
  }

  # multivariate apply to map over the inputs for repeated application of
  # the standard normal variate to already preprocessed sets.
  # If `spc_list` has length 1, it is repeated to fit the number of rows
  # supplied in the preprocessing plan. Different modes of parallelization are
  # available, which can be controlled in the global environment of the user
  # via `future::plan()`
  spc_prep_list <- future.apply::future_lapply(
    spc_list,
    snv_impl,
    future.seed = 1L
  )

  if (is.null(dt_prep_sets)) {
    # Prepare output;
    # fresh preprocessing labels; no parameter necessary
    dt_prep <- data.table(
      prep_set = "snv", prep_label = "snv", prep_params = NULL
    )
    # add list of spectra processed with Standard Normal Variate (SNV)
    # as list-column
    dt_prep[, spc_prep := spc_prep_list]
  } else {
    dt_prep <- copy(dt_prep_sets[, .(prep_set, prep_label, prep_params)])
    # extend (list append) data frame columns
    dt_prep[, `:=`(
      prep_set = paste0(prep_set, "-snv"),
      prep_label = paste0(prep_label, "-snv"),
      prep_params = lapply(prep_params, function(x) {
        cbind(x, data.table(snv = NA))
      })
    )]

    # append the newly processed spectra
    dt_prep[, spc_prep := spc_prep_list]

    if (isTRUE(append_rows)) {
      # row bind newly processed spectra with supplied spectra
      dt_out <- rbindlist(
        list(
          dt_prep_sets, # input as supplied
          dt_prep
        ) # preprocessed based on input
      )
    } else {
      # return only newly processed spectra
      dt_out <- dt_prep
    }

    return(dt_out)
  }
}

#' @noRd
#' @importFrom matrixStats rowMeans2 rowSds
snv_impl <- function(X) {
  if (!is.matrix(X)) {
    stopifnot(
      "`X` needs to be either a matrix or a data frame" =
        is.data.frame(X)
    )
    X <- as.matrix(X)
  }
  X <- sweep(X, 1L, matrixStats::rowMeans2(X, na.rm = TRUE), `-`)
  X <- sweep(X, 1L, matrixStats::rowSds(X, na.rm = TRUE), `/`)
  X <- as.data.table(X)
  return(X)
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
