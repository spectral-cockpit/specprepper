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
  }
  lst_vec <- list(vec_row, vec_id, vec_group)
  stopifnot(
    "`vec_row`, `vec_id`, and `vec_by` must have equal length" =
      all(vapply(lst_vec, length, integer(1L)) == length(lst_vec[[1]]))
  )

  if (!is.null(dt_prep_sets)) {
    checkset_dt_prep_sets(dt_prep_sets)
    lst_nrow_spc_prep <-
      stopifnot(
        "All spectra in in list-column `spc_prep` must have the same length
        for labeling" = all(
          vapply(
            dt_prep_sets$spc_prep, nrow, integer(1L)
          ) ==
            nrow(dt_prep_sets[[1]])
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
      prep_params = c(NULL),
      id_labels = id_labels,
      spc_prep = spc_list
    )
  } else {

  }
}
