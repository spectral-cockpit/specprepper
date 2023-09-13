<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

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
