#' Combinatory Savitzky-Golay Filtering
#' @description Apply Savitzky-Golay filtering at variable combinations of
#'   parameter sets for set(s) of spectra.
#' @param X `matrix`, `data.frame` or `data.table` with spectra to be
#' preprocessed according to plan (see `dt_sg_plan`).
#' @param dt_sg_plan A standardized `data.table` with the Savitzky-Golay
#' parameter sets, which can be generated with `sg_plan()`. It must at least
#' contain the following columns:
#' * `prep_set` (character)
#' * `prep_label` (character)
#' * `m` (integer): order of the derivative; `m = 0` signifies no derivative
#' * `p` (integer): polynomal order
#' * `w` (integer): window size in number of spectral points; must be uneven
#' `m` is the , `p` is the polynomial order
#' that should be bigger than the derivative order,  and `w` is the window size
#'  in  number of spectral points (must be uneven). See section
#'  *Savitzky-Golay Plan* for templating the required object and
#' [prospectr::savitzkyGolay()] for further the original Savitzky-Golay
#' algorithm.
#' @param dt_prep_sets A standardized `data.table`, i.e. returned from `specprepper::*_apply()`
#' function. Contains labelled sets of preprocessed spectra:
#' This argument allows to chain preprocessing in sequential manner, and i.e. apply variable
#' Savitzky-Golay smoothers with a single function application.
#' @param nest_params logical whether to nest the Savitzky-Golay parameters in
#' a `prep_params` list-column.
#' @param append_rows logical whether to append the newly processed rows, when
#' `dt_prep_sets` is not NULL.
#' @details
#' ## Design principles
#' Savitzky-Golay transformation (moving window polynomial least-squares) prior modeling can help
#' to reduce noise and enhance signals in spectra. This can allowing models to extract parsimonious
#' predictable information from spectra for more accurate estimation. However, this process requires
#' empirical optimization and fine-tuning of the parameters that control the nature and degree of
#' smoothing and hence noise removal for calibration task at hand, which is often not done. For
#' example, systematically varying the size of the smoothing window control the amount of
#' information filtered and potential artefacts created. Nonetheless, non-stationary noise as
#' opposed to white gaussian noise and informative fluctuations in chemically-driven spectral
#' dynamics (e.g. slope changes and different absorption peak widths and compositional complexity)
#' can make a simple nonrecursive application of the original Savitzky-Golay algorithm less
#' appropriate to filter noise.
#'
#' Templating code for sequential and/or recursive branching of preprocessing methods with variation
#' their parameters, if applicable, can be repetitive and cumbersome. This is where the specprep
#' package with combinatory planning and application tools jumps in.
#'
#' The combinatory power of the `sg_apply()` function stems from the ability to map Savitzly Golay
#' both over row-wise sets of parametrizations (see subsection *Savitzky-Golay Plan*) and previous
#' preprocessing rounds that yielded set(s) of (differently) processed spectra to be processed again
#' (see section *Set(s) of Previously Processed Spectra*). Since `data.table`s are structured
#' consistently across the `specprep::*_apply` type of functions, their inputs and outputs are
#' interoperable. This allows flexiblity for applying combinations of preprocessing methods.
#' ## Savitzky-Golay Plan
#' `dt_sg_plan` is most conventiently built with `sg_plan()`. It parametrizes Savitzky-Golay
#' preprocessing scheduled on either `X` or on all sets of already processed spectra contained in
#' `dt_prep_sets`. Each row lays out one preprocessing step, linking the following data across
#' columns:
#' * `prep_set`: this string identifies the name of general preprocessing method that is chained
#' to sets of spectra.
#' ## Set(s) of Previously Processed Spectra
#' tbd
#' @return data.table with the following (list)columns:by
#' #to be filled
#' @author Philipp Baumann
#' @importFrom prospectr savitzkyGolay
#' @export
sg_apply <- function(X,
                     dt_sg_plan,
                     dt_prep_sets = NULL,
                     nest_params = TRUE,
                     append_rows = FALSE) {
  if (!missing(X)) {
    stopifnot(
      is.matrix(X) || is.data.frame(X),
      is.data.frame(dt_sg_plan) && nrow(dt_sg_plan) != 0
    )
  }

  prep_params <- prep_params_in <- prep_set <- prep_label <- spc_prep <- m <-
    p <- w <- NULL

  # Set processing plan object to data.table if it is not yet one
  if (!is.data.table(dt_sg_plan)) setDT(dt_sg_plan)

  if (!is.null(dt_prep_sets)) {
    stopifnot(is.data.frame(dt_prep_sets))
    if (!"spc_prep" %in% colnames(dt_prep_sets)) {
      stop(strwrap(
        "`data.table` `dt_prep_sets` requires the column named `spc_prep`,
         which contains a list of already processed spectra",
        prefix = "\n"
      ))
    }
    if (!is.data.table(dt_prep_sets)) setDT(dt_prep_sets)
  }

  # Copy to avoid modifying the input data.table in place; low-memory object
  dt_sg_plan <- copy(dt_sg_plan) # use explicit copy

  if (is.null(dt_prep_sets)) {
    # use X as single set of spectra
    m_vec <- dt_sg_plan$m
    p_vec <- dt_sg_plan$p
    w_vec <- dt_sg_plan$w
    # X as single set of spectra: wrap one matrix or data.frame into list
    # for mapping
    spc_list <- list(X)
  } else {
    # make data.table with full-factorial combination of sets of already
    # processed spectra (list-column) and planned parameter sets for which
    # Savitzky-Golay function will be invoked
    dt_prep <- sg_make_dt_prep(dt_sg_plan, dt_prep_sets)

    m_vec <- dt_prep$m
    p_vec <- dt_prep$p
    w_vec <- dt_prep$w

    # Get list of data.frames/matrices/data.tables with spectra to be processed
    # from list-column
    spc_list <- dt_prep$spc_prep
    dt_prep[, spc_prep := NULL]
  }

  # syntax identical to `base::Map()`; multivariate apply to map over the
  # inputs for repeated application of Savitzky-Golay. If `spc_list` has length 1,
  # it is repeated to fit the number of rows supplied in the preprocessing plan.
  # Different modes of parallelization are available, which can be controlled
  # in the global environment of via `future::plan()`
  spc_prep_list <- future.apply::future_Map(
    function(spc_list, m_vec, p_vec, w_vec) {
      as.data.table(
        prospectr::savitzkyGolay(X = spc_list, m = m_vec, p = p_vec, w = w_vec)
      )
    },
    spc_list,
    m_vec,
    p_vec,
    w_vec,
    future.seed = 1L
  )

  if (is.null(dt_prep_sets)) {
    # Prepare output
    dt_out <- copy(dt_sg_plan)

    if (isTRUE(nest_params)) {
      # wrap parameter columns of plan into list
      dt_out[, prep_params := .(list(.SD)), by = .(prep_set, prep_label)]
      # add list of spectra processed with Savitzky-Golay as list-column
      dt_out[, c("m", "p", "w") := NULL][, spc_prep := spc_prep_list]
    }

    # add list of spectra processed with Savitzky-Golay as list-column
    dt_out[, spc_prep := spc_prep_list]
  } else {
    if ("prep_params" %in% colnames(dt_prep)) {
      dt_prep[, prep_params_in := prep_params]
    }
    # replace the old parameter set column (`prep_params`) with
    # nested Savitzky-Golay parameters in list-column (rowwise)
    dt_prep[
      , prep_params := Map(function(m, p, w) {
        data.table(m = m, p = p, w = w)
      }, m, p, w)
    ][
      , c("m", "p", "w") := NULL
    ]

    if ("prep_params_in" %in% colnames(dt_prep)) {
      dt_prep[, prep_params := Map(
        function(x, y) cbind(x, y),
        prep_params_in, prep_params
      )][, prep_params_in := NULL]
    }

    # append newly preprocessed data
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
  }

  return(dt_out)
}


# Helper to chain different preprocessing methods: there is already a list of
# preprocessed spectra, for each of which new Savitzky-Golay filters are
# applied; do a full factorial (cartesian) combination of list of spectra
# use `prep_label` column vector to create join identifiers;
# length of `prep_joins` is nrow(dt_prep_sets) times nrow(dt_sg_plan)

sg_make_dt_prep <- function(dt_sg_plan,
                            dt_prep_sets) {
  . <- prep_label_cb <- prep_set <- prep_set_cb <- prep_label <- NULL
  prep_joins <- CJ(
    prep_label = dt_prep_sets$prep_label,
    prep_label_cb = dt_sg_plan$prep_label
  )
  # inner-join to select repeated parameter combinations; keep matching
  # parameters; "cb" suffix stands for "combinator"
  prep_joined_cb <- prep_joins[, .(prep_label_cb)]
  setnames(dt_sg_plan,
    old = c("prep_set", "prep_label"),
    new = c("prep_set_cb", "prep_label_cb")
  )
  sg_params <- dt_sg_plan[prep_joined_cb,
    allow.cartesian = TRUE, # explicit option to allow for duplicates in i
    on = "prep_label_cb",
    nomatch = NULL
  ] # inner join
  # Multiply the list spectra in the right order of the cross-join
  # (`prep_joins`) and then join the data.table with
  # Savitzky-Golay parameter sets
  prep_joined_spc <- dt_prep_sets[prep_joins,
    allow.cartesian = TRUE,
    on = "prep_label",
    nomatch = NULL
  ]
  setkey(prep_joined_spc, prep_label_cb)
  setkey(sg_params, prep_label_cb)
  # match is only possible with unique keys; `prep_label_cb` contains
  # purposely duplicated strings; create row number as primary sorting key(s)
  prep_joined_spc[, rowid := seq_len(.N)]
  setkey(prep_joined_spc, rowid)
  sg_params[, rowid := seq_len(.N)]
  setkey(sg_params, rowid)
  dt_prep <- prep_joined_spc[sg_params[, prep_label_cb := NULL],
    nomatch = NULL
  ]
  # remove `rowid` by reference and combine the old and new preprocessing
  # identifiers into one
  dt_prep[, rowid := NULL]
  dt_prep[, `:=`(
    prep_set = paste0(prep_set, "-", prep_set_cb),
    prep_label = paste0(prep_label, "-", prep_label_cb),
    prep_label_cb = NULL,
    prep_set_cb = NULL
  )]

  return(dt_prep)
}


#' Generate a data.frame with Savitzky-Golay parameters
#' @description Make a full-factorial combination of Savitzky-Golay parameters.
#' @param param_list A list of
#' @return data.frame
#' @author Philipp Baumann
#' @importFrom prospectr savitzkyGolay
#' @export
sg_make_plan <- function(param_list) {
  m <- p <- w <- prep_label <- prep_set <- NULL
  if (!requireNamespace("data.table")) {
    stop("Package data.table needs to be attached")
  }
  # tbd: defensive checks
  stopifnot(is.list(param_list), all(sapply(unlist(param_list), is.numeric)))
  if (all(nzchar(names(param_list)))) {
    prep_set_nm <- names(param_list) # non-empty names
  } else {
    prep_set_nm <- paste0("set_", seq_along(param_list))
  }
  # Row bind multiple cross joins (CJ)
  sg_params <- rbindlist(
    Map(
      function(x, y) CJ(m = x$m, p = x$p, w = x$w)[, prep_set := y],
      param_list, prep_set_nm
    )
  )
  sg_params[, prep_label := paste0("sg_m", m, "_p", p, "_w", w)]
  setcolorder(sg_params, c("prep_set", "prep_label", "m", "p", "w"))
  return(sg_params)
}
