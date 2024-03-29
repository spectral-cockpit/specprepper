% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ids-apply.R
\name{ids_apply}
\alias{ids_apply}
\title{Add atomic vector labels for row, id and group for all rows of spectra.}
\usage{
ids_apply(X, dt_prep_sets = NULL, vec_row, vec_id, vec_group)
}
\arguments{
\item{X}{\code{matrix}, \code{data.frame} or \code{data.table} for which label rows
are to be applied.}

\item{dt_prep_sets}{A standardized \code{data.table}, i.e. returned from \verb{specprepper::*_apply()}
function. Contains labelled sets of preprocessed spectra:
This argument allows to chain preprocessing in sequential manner, and i.e. apply variable
Savitzky-Golay smoothers with a single function application.}

\item{vec_row}{atomic vector with row labels; need to have same length
as \code{nrow(X)} or rows in all \code{spc_proc} list-column data.table's.}

\item{vec_id}{atomic vector with id labels, needs to have same length
as \code{nrow(X)} or rows in all \code{spc_proc} list-column data.table's. \code{id_vec}
typically represents the smallest hiararchical unit in the measurement
design, e.g., a replicate spectrum measured.}

\item{vec_group}{atomic vector with group labels; needs to have same length
as \code{nrow(X)} or rows in all \code{spc_proc} list-column data.table's. \code{id_group}
typically represents the group to aggregate by in specific methods applied
later. Currently, this is \code{colmean_group_apply()} that takes grouped means
of spectra or collections of spectra.}
}
\value{
If \code{X} is specified:
\itemize{
\item A one-row \code{"data.table"} with the following columns
\itemize{
\item \code{prep_set}: \code{"init_ids"},
\item \code{prep_label}: \code{"prep_label"}
\item \code{prep_params}: list-column of length 1 with \code{"data.table"} containing
\code{init_ids = NA}
\item \code{id_labels}: list-column (repeated across rows) with \code{"data.table"}
containing columns with labels: \code{row} (from \code{vec_row}),
\code{id}  (from \code{vec_id}), and \code{group} (from \code{vec_group}).
If \code{dt_prep_sets} is specified:
}
\item A \code{"data.table"} with as many rows as spectral collections. A spectral
collection typically represents an outcome of one or more specific
preprocessing with methods and possibly associated parameters used.
Specifically, it augments the input \code{dt_prep_sets} and outputs the
following (list-)columns:
\itemize{
\item \code{prep_set}: appends \verb{"-init_ids} to the input string that states what
the main preprocessings done in previous steps.
\item \code{prep_label}: appends \verb{"-init_ids} to the input string that states what
was done with abbreviations of methods in previous steps.
\item \code{prep_params}: augments each data.table element in the list-column with
a new non-specific column \code{init_ids = NA} (indicating a new label
column but no direct effect on the processed spectra).
\item \code{id_labels}: new list-column that contains a set of labels that applies
for all spectral collections nested within respective rows of the
\code{dt_prep_sets} input. Each data.table in the list contains the label
columns \code{row} (from \code{vec_row}),\code{id} (from \code{vec_id}), and \code{group}
(from \code{vec_group}).
\item \code{spec_prep}: unmodified list-column with sets of already prepared,
processed spectra. Each element is a data.table which rows corresponds
to the row labels in \code{id_labels}.
}
}
}
\description{
Adds labels to rows of all individual spectra in collections.
Such labels are required for subsequent processing functions that aggregate
spectral collections by group, for example \code{colmean_group_apply()}.
It can also be used to initialize a single spectral collection with labels
when inputting a single matrix, data frame or data.table.
}
