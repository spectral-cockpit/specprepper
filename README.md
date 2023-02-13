
# Overview

This package is born from the idea that preprocessing methods in spectroscopy modeling are rather empirical in nature.

This is a very early, unstable version of the package. The goal is to wrap different signal processing methods and to chain them in sequence. For in memory structures, we rely on matrix class with attributes, where on disk side we use the zarr data structure for persistence and speed.

To schedule propreprocessing operations, simple tooling using S3 descriptive data.tables are used.