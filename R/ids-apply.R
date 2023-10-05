#' Add atomic vector labels for row, id and group for all rows of spectra.
#'
#' @description Adds labels to rows of all individual spectra in collections.
#' Such labels are required for subsequent processing functions that aggregate
#' spectral collections by group, for example `colmean_group_apply()`.
#' It can also be used to initialize a single spectral collection with labels
#' when inputting a single matrix, data frame or data.table.
#' @param X `matrix`, `data.frame` or `data.table` for which label rows
#' are to be applied.
#' @param vec_row atomic vector with row labels; need to have same length
#' as `nrow(X)` or rows in all `spc_proc` list-column data.table's.
#' @param vec_id atomic vector with id labels, needs to have same length
#' as `nrow(X)` or rows in all `spc_proc` list-column data.table's. `id_vec`
#' typically represents the smallest hiararchical unit in the measurement
#' design, e.g., a replicate spectrum measured.
#' @param vec_group atomic vector with group labels; needs to have same length
#' as `nrow(X)` or rows in all `spc_proc` list-column data.table's. `id_group`
#' typically represents the group to aggregate by in specific methods applied
#' later. Currently, this is `colmean_group_apply()` that takes grouped means
#' of spectra or collections of spectra.
#' @return If `X` is specified:
#' * A one-row `"data.table"` with the following columns
#'   * `prep_set`: `"init_ids"`,
#'   * `prep_label`: `"prep_label"`
#'   * `prep_params`: list-column of length 1 with `"data.table"` containing
#'     `init_ids = NA`
#'   * `id_labels`: list-column (repeated across rows) with `"data.table"`
#'      containing columns with labels: `row` (from `vec_row`),
#'       `id`  (from `vec_id`), and `group` (from `vec_group`).
#' If `dt_prep_sets` is specified:
#' * A `"data.table"` with as many rows as spectral collections. A spectral
#'   collection typically represents an outcome of one or more specific
#'   preprocessing with methods and possibly associated parameters used.
#'   Specifically, it augments the input `dt_prep_sets` and outputs the
#'   following (list-)columns:
#'   * `prep_set`: appends `"-init_ids` to the input string that states what
#'       the main preprocessings done in previous steps.
#'   * `prep_label`: appends `"-init_ids` to the input string that states what
#'       was done with abbreviations of methods in previous steps.
#'   * `prep_params`: augments each data.table element in the list-column with
#'       a new non-specific column `init_ids = NA` (indicating a new label
#'       column but no direct effect on the processed spectra).
#'   * `id_labels`: new list-column that contains a set of labels that applies
#'      for all spectral collections nested within respective rows of the
#'      `dt_prep_sets` input. Each data.table in the list contains the label
#'      columns `row` (from `vec_row`),`id` (from `vec_id`), and `group`
#'      (from `vec_group`).
#'   * `spec_prep`: unmodified list-column with sets of already prepared,
#'      processed spectra. Each element is a data.table which rows corresponds
#'      to the row labels in `id_labels`.
#' @inheritParams sg_apply
#' @export
ids_apply <- function(X,
                      dt_prep_sets = NULL,
                      vec_row,
                      vec_id,
                      vec_group) {
  if (!missing(X)) {
    stopifnot(
      "`X` needs to be data frame (including data.table) or matrix" =
        is.matrix(X) || is.data.frame(X)
    )
    if (is.matrix(X)) {
      X <- as.data.table(X)
    } else if (!is.data.table(X)) {
      X <- setDT(X)
    }
  }

  prep_label <- prep_params <- prep_set <- NULL

  lst_vec <- list(vec_row, vec_id, vec_group)
  stopifnot(
    "`vec_row`, `vec_id`, and `vec_by` must have equal length" =
      all(vapply(lst_vec, length, integer(1L)) == length(lst_vec[[1L]]))
  )

  if (!is.null(dt_prep_sets)) {
    checkset_dt_prep_sets(dt_prep_sets)
    stopifnot(
      "All spectra in in list-column `spc_prep` must have the same numbers
        of rows to apply ID labels" = all(
        vapply(
          dt_prep_sets$spc_prep, nrow, integer(1L)
        ) == nrow(dt_prep_sets[[1L]])
      )
    )
  }

  id_labels <- list(
    data.table(
      row = vec_row,
      id = vec_id,
      group = vec_group
    )
  )

  if (is.null(dt_prep_sets)) {
    spc_list <- list(X)
    dt_prep <- data.table(
      prep_set = "init_ids",
      prep_label = "init_ids",
      prep_params = list(data.table(init_ids = NA)),
      id_labels = id_labels,
      spc_prep = spc_list
    )
  } else {
    dt_prep <- copy(dt_prep_sets)
    nms <- colnames(dt_prep)
    which_spc <- which(nms == "spc_prep")
    new_nms <- c(nms[seq_len(which_spc - 1L)], "id_labels", "spc_prep")
    dt_prep[, `:=`(
      prep_set = paste0(prep_set, "-init_ids"),
      prep_label = paste0(prep_label, "-init_ids"),
      prep_params = lapply(prep_params, function(x) {
        cbind(x, data.table(init_ids = NA))
      }),
      id_labels = rep(id_labels, nrow(dt_prep))
    )]
    setcolorder(dt_prep, new_nms)
  }

  return(dt_prep)
}
