
# Overview

This package is born from the idea that preprocessing methods in spectroscopy modeling are rather empirical in nature.

This is a very early, unstable version of the package. The goal is to wrap different signal processing methods and to chain them in sequence. For in memory structures, we rely on matrix class with attributes, where on disk side we use the zarr data structure for persistence and speed.

To schedule propreprocessing operations, simple tooling using S3 descriptive data.tables are used. So to speak it provides a recipe-like interface to configure methods and parameters to be applied in future. Hence the promising name. Because of the cloud-native nature of zarr, certainly once can use S3-like storages as MINIO.

The algorithmic side is provided by excellent {prospectr}, and {data.table} 
provides memory-efficient mappings.

# Getting started

```r
if (!requireNamespace("remotes") install.packages("remotes"))
remotes::install_github("spectral-cockpit/specprepper")
```

```r
library("data.table")
spec_dt <- qs::qread(file = file.path("inst", "extdata", "spec_dt"))
(spec <- spec_dt$.predictor_values[[1]])

make_sg_param_list <- function(sg_windows = c(5L, 9L, 13L, 15L, 17L, 19L, 21L,
                                              23L, 25L, 27L, 35L)) {
  list(
    sg_1 = list(m = 1L, p = c(2L, 3L), w = sg_windows),
    sg_2 = list(m = 2L, p = c(3L, 4L), w = sg_windows)
  )
}

make_preproc_plan <- function() {
  param_list <- make_sg_param_list()
  preproc_plan <- specprepper::sg_make_plan(param_list = param_list)
  return(preproc_plan)
}

preproc_plan <- make_preproc_plan()
```