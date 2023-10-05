<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# specprepper 0.3.2 (2023-10-05)

- `snv_apply(X)`: add `prep_params` as list-column with a single-row data.table (`snv = NA`)
  to the output when `X` is provided. This makes binding outputs to other (pre)processed collections
  of spectra possible without further intervention; also, `append_rows = TRUE` will work
  with other methods, when output of `snv_apply()` is used as input of other `*_apply()`
  functions.


# specprepper 0.3.1.9000 (2023-10-05)

## Fixes

- `sg_apply()`: allow joins of Savitzky-Golay plans and preprocessing labels, and then also prepared
   Savitzky-Golay plans with inputted `dt_prep_sets`, when there is duplicated `i`s.
   This is the case when `dt_prep_sets` input has already multiple rows (multiple collections) of spectra.
   Now, the desired duplicate joins are explicitly allowed by setting `allow.cartesian = TRUE` for
   respective data.table joins inside the `sg_make_dt_prep()` helper.

# specprepper 0.3.0 (2023-10-05)

## Features

- Implement `colmean_group_apply()` and group label constructor `ids_apply.R()`. This is to apply column means to to spectral
  collections, each by a group label.

# specprepper 0.2.1 (2023-09-13)

- patch `sg_apply()` so that the extra `"-snv"` that got accidentally added
  to both `prep_set` and `prep_label` is not there anymore.


# specprepper 0.2.0 (2023-09-13)

- patch `sg_apply()`, so that it can be run after e.g. `snv_apply()` (via
  `dt_prep_sets` input argument).


# specprepper 0.1.0 (2023-09-09)

## Features

- added `snv_apply()` to compute the standard normal variate (SNV) of
  spectral collections ([#15](https://github.com/spectral-cockpit/specprepper/pull/15)).
- added `sg_apply()` to process spectral collections with Savitzky-Golay
  smoothers with different parameter sets (derivative order, window size, 
  polynomial degree).

## Chores

- Started semantic versioning via {fledge}

# specprepper

Chemometrics and machine learning offer a large set of mathematical tooling to extract and apply chemical and physical knowledge from spectra in automated fashion. For this, spectra are typically preprocessed as part of the workflow. This is mostly to reduce light scattering and other optical artefacts.

The goal of {specprepper} is not only to wrap different signal processing methods and make them more accessible, but also to offer some of the exisiting algorithms with faster code implementations. It features a recipe-like interface, which also makes it possible to chain different methods in sequence.

