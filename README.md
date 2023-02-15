
# Overview

## Preamble

This package is born from the idea that preprocessing methods in spectroscopy modeling are rather empirical in nature.

This is a very early, unstable version of the package. The goal is to wrap different signal processing methods and to chain them in sequence. For in memory structures, we rely on matrix class with attributes, where on disk side we use the zarr data structure for persistence and speed.

Please first check and estimate the memory availability on your system when using in-memory features.

## Scope of application

This is a meta package that aims to provide both data-dependent and data
independent preprocessing method. The former implies that the processing of 
test data depends on the training data. For example, multiplicative scatter 
correction (MSC) needs special teatment in training, evaluation and prediction
workflows. That has implications for overfitting and data independence.

## Goals

To schedule propreprocessing operations, simple tooling using S3 descriptive data.tables are used. So to speak it provides a recipe-like interface to configure methods and parameters to be applied in future. Hence the promising name. Because of the cloud-native nature of zarr, certainly one can use S3-like storages as MINIO.

The algorithmic side is provided by excellent {prospectr}, and {data.table} 
plus {future.apply} map-reduce API provide memory-efficient mappings.

{specprepper} works with sticky attributes that are pinned to matrix or data.tables via {sticky}. This means
that processing function respect all preexisting attributes and do not strip
them in the returned output.

The roadmap is subject to change because this package is still maturing.
I am also looking into Julia modules for further extension. For wavelets,
Wavelets.jl seems very promising.

Despite all, modular packaging is key. As a matter of fact, future will show 
how many things we can do in one module.

This R meta library with fused python/julia/rust code is mainly intended 
for creating containerized environments for preprocessing.

## Currently supported methods

- Savitzky-Golay smoothing

## Planned methods

- Different wavelet transforms
- Binning/bucketing
- Standard Normal Variate
- Bruker Inc custom vector normalization
- 1-D Gaussian pyramid (armadillo binding) aka weighted moving average filter
- Ordination methods

# Getting started

## Installation

```r
if (!requireNamespace("remotes") install.packages("remotes"))
remotes::install_github("spectral-cockpit/specprepper")
```

## Prepare test data

```r
library("data.table")
# load example data
spec_dt <- qs::qread(file = file.path("inst", "extdata", "spec_dt"))
spec <- spec_dt$.predictor_values[[1]]
# x-values as wavenumbers
```
## Glue sticky attributes

```r
library("sticky")
sticky(spec)
```

Inspect the data quickly.

```r
r$> spec_dt
         .dims        .idx_row        .predictor_values                                         .predictor_labels
1: 10874, 3578 1,2,3,4,5,6,... <data.table[10874x3578]> 7497.969,7496.041,7494.112,7492.184,7490.255,7488.327,...
r$> dim(spec)
[1] 10874  3578
```


## Parameterize Savitzky-Golay filters

We create a custom list and expand it to a preprocessing plan.

```r
make_sg_param_list <- function(sg_windows = c(5L, 9L, 13L, 15L, 17L, 19L, 21L,
                                              23L, 25L, 27L, 35L)) {
  param_list <- list(
    sg_1 = list(m = 1L, p = c(2L, 3L), w = sg_windows),
    sg_2 = list(m = 2L, p = c(3L, 4L), w = sg_windows)
  )
  return(param_list)
}

make_preproc_plan <- function() {
  param_list <- make_sg_param_list()
  preproc_plan <- specprepper::sg_make_plan(param_list = param_list)
  return(preproc_plan)
}

preproc_plan <- make_preproc_plan()
```

We now inspect the plan.

```r
r$> preproc_plan
    prep_set   prep_label m p  w
 1:     sg_1  sg_m1_p2_w5 1 2  5
 2:     sg_1  sg_m1_p2_w9 1 2  9
 3:     sg_1 sg_m1_p2_w13 1 2 13
 4:     sg_1 sg_m1_p2_w15 1 2 15
 5:     sg_1 sg_m1_p2_w17 1 2 17
 6:     sg_1 sg_m1_p2_w19 1 2 19
 7:     sg_1 sg_m1_p2_w21 1 2 21
 8:     sg_1 sg_m1_p2_w23 1 2 23
 9:     sg_1 sg_m1_p2_w25 1 2 25
10:     sg_1 sg_m1_p2_w27 1 2 27
11:     sg_1 sg_m1_p2_w35 1 2 35
12:     sg_1  sg_m1_p3_w5 1 3  5
13:     sg_1  sg_m1_p3_w9 1 3  9
14:     sg_1 sg_m1_p3_w13 1 3 13
15:     sg_1 sg_m1_p3_w15 1 3 15
16:     sg_1 sg_m1_p3_w17 1 3 17
17:     sg_1 sg_m1_p3_w19 1 3 19
18:     sg_1 sg_m1_p3_w21 1 3 21
19:     sg_1 sg_m1_p3_w23 1 3 23
20:     sg_1 sg_m1_p3_w25 1 3 25
21:     sg_1 sg_m1_p3_w27 1 3 27
22:     sg_1 sg_m1_p3_w35 1 3 35
23:     sg_2  sg_m2_p3_w5 2 3  5
24:     sg_2  sg_m2_p3_w9 2 3  9
25:     sg_2 sg_m2_p3_w13 2 3 13
26:     sg_2 sg_m2_p3_w15 2 3 15
27:     sg_2 sg_m2_p3_w17 2 3 17
28:     sg_2 sg_m2_p3_w19 2 3 19
29:     sg_2 sg_m2_p3_w21 2 3 21
30:     sg_2 sg_m2_p3_w23 2 3 23
31:     sg_2 sg_m2_p3_w25 2 3 25
32:     sg_2 sg_m2_p3_w27 2 3 27
33:     sg_2 sg_m2_p3_w35 2 3 35
34:     sg_2  sg_m2_p4_w5 2 4  5
35:     sg_2  sg_m2_p4_w9 2 4  9
36:     sg_2 sg_m2_p4_w13 2 4 13
37:     sg_2 sg_m2_p4_w15 2 4 15
38:     sg_2 sg_m2_p4_w17 2 4 17
39:     sg_2 sg_m2_p4_w19 2 4 19
40:     sg_2 sg_m2_p4_w21 2 4 21
41:     sg_2 sg_m2_p4_w23 2 4 23
42:     sg_2 sg_m2_p4_w25 2 4 25
43:     sg_2 sg_m2_p4_w27 2 4 27
44:     sg_2 sg_m2_p4_w35 2 4 35
    prep_set   prep_label m p  w
```

## Prepare futures

```r
library("future")
plan(multisession)
```

## Launch the preprocessing prepper

```r
spec_proc <- sg_apply(
  X = spec,
  dt_sg_plan = preproc_plan
)

```

## Inspect the results

```r
r$> spec_proc
    prep_set   prep_label       prep_params                 spc_prep
 1:     sg_1  sg_m1_p2_w5 <data.table[1x3]> <data.table[10874x3574]>
 2:     sg_1  sg_m1_p2_w9 <data.table[1x3]> <data.table[10874x3570]>
 3:     sg_1 sg_m1_p2_w13 <data.table[1x3]> <data.table[10874x3566]>
 4:     sg_1 sg_m1_p2_w15 <data.table[1x3]> <data.table[10874x3564]>
 5:     sg_1 sg_m1_p2_w17 <data.table[1x3]> <data.table[10874x3562]>
 6:     sg_1 sg_m1_p2_w19 <data.table[1x3]> <data.table[10874x3560]>
 7:     sg_1 sg_m1_p2_w21 <data.table[1x3]> <data.table[10874x3558]>
 8:     sg_1 sg_m1_p2_w23 <data.table[1x3]> <data.table[10874x3556]>
 9:     sg_1 sg_m1_p2_w25 <data.table[1x3]> <data.table[10874x3554]>
10:     sg_1 sg_m1_p2_w27 <data.table[1x3]> <data.table[10874x3552]>
11:     sg_1 sg_m1_p2_w35 <data.table[1x3]> <data.table[10874x3544]>
12:     sg_1  sg_m1_p3_w5 <data.table[1x3]> <data.table[10874x3574]>
13:     sg_1  sg_m1_p3_w9 <data.table[1x3]> <data.table[10874x3570]>
14:     sg_1 sg_m1_p3_w13 <data.table[1x3]> <data.table[10874x3566]>
15:     sg_1 sg_m1_p3_w15 <data.table[1x3]> <data.table[10874x3564]>
16:     sg_1 sg_m1_p3_w17 <data.table[1x3]> <data.table[10874x3562]>
17:     sg_1 sg_m1_p3_w19 <data.table[1x3]> <data.table[10874x3560]>
18:     sg_1 sg_m1_p3_w21 <data.table[1x3]> <data.table[10874x3558]>
19:     sg_1 sg_m1_p3_w23 <data.table[1x3]> <data.table[10874x3556]>
20:     sg_1 sg_m1_p3_w25 <data.table[1x3]> <data.table[10874x3554]>
21:     sg_1 sg_m1_p3_w27 <data.table[1x3]> <data.table[10874x3552]>
22:     sg_1 sg_m1_p3_w35 <data.table[1x3]> <data.table[10874x3544]>
23:     sg_2  sg_m2_p3_w5 <data.table[1x3]> <data.table[10874x3574]>
24:     sg_2  sg_m2_p3_w9 <data.table[1x3]> <data.table[10874x3570]>
25:     sg_2 sg_m2_p3_w13 <data.table[1x3]> <data.table[10874x3566]>
26:     sg_2 sg_m2_p3_w15 <data.table[1x3]> <data.table[10874x3564]>
27:     sg_2 sg_m2_p3_w17 <data.table[1x3]> <data.table[10874x3562]>
28:     sg_2 sg_m2_p3_w19 <data.table[1x3]> <data.table[10874x3560]>
29:     sg_2 sg_m2_p3_w21 <data.table[1x3]> <data.table[10874x3558]>
30:     sg_2 sg_m2_p3_w23 <data.table[1x3]> <data.table[10874x3556]>
31:     sg_2 sg_m2_p3_w25 <data.table[1x3]> <data.table[10874x3554]>
32:     sg_2 sg_m2_p3_w27 <data.table[1x3]> <data.table[10874x3552]>
33:     sg_2 sg_m2_p3_w35 <data.table[1x3]> <data.table[10874x3544]>
34:     sg_2  sg_m2_p4_w5 <data.table[1x3]> <data.table[10874x3574]>
35:     sg_2  sg_m2_p4_w9 <data.table[1x3]> <data.table[10874x3570]>
36:     sg_2 sg_m2_p4_w13 <data.table[1x3]> <data.table[10874x3566]>
37:     sg_2 sg_m2_p4_w15 <data.table[1x3]> <data.table[10874x3564]>
38:     sg_2 sg_m2_p4_w17 <data.table[1x3]> <data.table[10874x3562]>
39:     sg_2 sg_m2_p4_w19 <data.table[1x3]> <data.table[10874x3560]>
40:     sg_2 sg_m2_p4_w21 <data.table[1x3]> <data.table[10874x3558]>
41:     sg_2 sg_m2_p4_w23 <data.table[1x3]> <data.table[10874x3556]>
42:     sg_2 sg_m2_p4_w25 <data.table[1x3]> <data.table[10874x3554]>
43:     sg_2 sg_m2_p4_w27 <data.table[1x3]> <data.table[10874x3552]>
44:     sg_2 sg_m2_p4_w35 <data.table[1x3]> <data.table[10874x3544]>
    prep_set   prep_label       prep_params                 spc_prep

r$> format(object.size(spec_proc), units = "GB")
[1] "12.7 Gb"
```

# Credits

The main idea for this package came while working at the Swiss Competence
Center for Soils (KOBO). I have as well used internally some early prototype
of this package in my own research.