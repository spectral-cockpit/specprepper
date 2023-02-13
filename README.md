
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