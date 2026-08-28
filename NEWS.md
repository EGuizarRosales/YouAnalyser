# YouAnalyser 0.9.2

* Added a Price Sensitivity Meter (PSM) module, wrapping the `pricesensitivitymeter` package and adding YouGov-specific reporting helpers:
  * Re-exported `psm_analysis()` and `psm_analysis_weighted()` from `pricesensitivitymeter` for the (unweighted and weighted) van Westendorp analysis, including the Newton-Miller-Smith (NMS) extension.
  * `psm_design_for_weighted()` builds an unclustered `survey.design` object from a weight column, for use with `psm_analysis_weighted()`.
  * `psm_plot()` creates the classic van Westendorp price sensitivity plot (with the four cumulative distribution curves, indifference and optimal price points, and acceptable price range), plus reach and revenue optimization plots when the NMS extension was used.
  * `psm_save_data_for_chart()` and `psm_copy_pptx_template()` export PSM results into standardized Excel and PowerPoint templates, mirroring the existing KDA reporting workflow.
* Added a new vignette, `vignette("psm")`, demonstrating the PSM workflow end to end.
* Added `chm_synthetic`, a synthetic dataset (based on the 2025 CH Media Oneplus Streaming Markenstudie) with the four basic van Westendorp questions and the two NMS purchase-intention questions, for use in examples and the PSM vignette.

# YouAnalyser 0.9.1

* Initial submission.
* First version of the package, introducing:
  * Data processing (`dp_*`) functions for preparing and cleaning survey data (e.g., labelling, recoding missing values).
  * Exploratory data analysis (`eda_*`) functions for summarizing and visualizing survey data.
  * Key Driver Analysis (`kda_*`) functions, including regression-based importance metrics, handling of missing data via imputation, and standardized Excel/PowerPoint reporting templates.
