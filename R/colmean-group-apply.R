#' Compute the mean spectra per group label for all spectra in a collection
#' @description The function can be applied to spectral collections,
#' `dt_prep_sets`. The list-column `id_labels` with lists of data.tables each
#' containing a column named `group` must be present. See also `ids_apply()`.
#' @inheritParams sg_apply
#' @return
#' * A `"data.table"` with as many rows as spectral collections. It contains
#'   at least the following columns:
#'   * `prep_set`: appends `"-mean_group"` to the exisiting character vector
#'        elements of the input data.
#'   * `prep_label`: appends `"mean_group"` to the exisiting character vector
#'        elements of the input data.
#'   * `prep_params`: A list-column with 1-row data.table's. Each data.table has
#'        a new column `mean_group`, contains the string `"id_labels$group"`.
#'   * `id_labels`: This list-column now only contains a sliced version of the
#'        `group` column, that correspond to the new rows of the aggregated
#'        column means in `spc_prep`.
#'   * `spc_prep`: A list-column with data.tables that contain aggregated
#'        means of spectra by group for each spectral collection (row of
#'        `dt_prep_sets`)
#' @details A spectral collection typically represents an outcome of one or more
#' specific preprocessing with methods and possibly associated parameters used.
#' `colmean_group_apply()` only accepts collections with structural conventions
#' of `dt_prep_sets`. It requires a `id_labels` list-column with a `group`
#' column specifying the lables used for aggregation in each data.table element
#' (one for each collection). Label columns such as `row` or `id` that were
#' present before will be removed because they are assumed to be aggregated.
#' @export
colmean_group_apply <- function(dt_prep_sets,
                                append_rows = FALSE) {
  id_labels <- prep_label <- prep_params <- prep_set <- spc_prep <- NULL

  checkset_dt_prep_sets(dt_prep_sets)

  stopifnot(
    "Object `dt_prep_sets` needs to have `id_labels` list-column that contains
    grouping information. Apply `ids_apply() first`" =
      "id_labels" %in% colnames(dt_prep_sets)
  )

  all_groups <- all(
    vapply(
      dt_prep_sets$id_labels, function(x) "group" %in% colnames(x),
      logical(1L)
    )
  )

  stopifnot(
    "All data.tables in list-column `id_labels` need to have a `group` column" =
      all_groups
  )

  spc_list <- dt_prep_sets$spc_prep
  vec_group_list <- lapply(dt_prep_sets$id_labels, function(x) x$group)

  # multivariate apply to map over the inputs for repeated application of
  # taking the mean of all spectra per group for already preprocessed sets.
  # If `spc_list` has length 1, it is repeated to fit the number of rows
  # supplied in the preprocessing plan. Different modes of parallelization are
  # available, which can be controlled in the global environment of the user
  # via `future::plan()`
  spc_mean_list <- future.apply::future_Map(
    function(X, vec_group) colmean_group_apply_impl(X, vec_group),
    X = spc_list, vec_group = vec_group_list,
    future.seed = 1L
  )

  group_list <- lapply(spc_mean_list, `[[`, "group")
  group_list_dt <- lapply(group_list, function(x) data.table(group = x))

  dt_prep <- dt_prep_sets[, setdiff(names(dt_prep_sets), "spc_prep"),
    with = FALSE
  ]
  dt_prep[, `:=`(
    prep_set = paste0(prep_set, "-mean_group"),
    prep_label = paste0(prep_label, "-mean_group"),
    prep_params = lapply(prep_params, function(x) {
      cbind(x, data.table(mean_group = "id_labels$group"))
    }),
    id_labels = group_list_dt,
    spc_prep = lapply(spc_mean_list, `[[`, "X_mean")
  )]

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

#' @noRd
colmean_group_apply_impl <- function(X, vec_group) {
  stopifnot(
    "`X` needs to be a data.table" =
      is.data.table(X)
  )
  suppressWarnings({
    X[, group := vec_group]
  })
  X_mean <- X[, lapply(.SD, mean), by = "group"]
  group <- X_mean$group
  X_mean[, group := NULL]

  lst_out <- list(X_mean = X_mean, group = group)

  return(lst_out)
}
