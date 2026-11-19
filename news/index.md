# Changelog

## YouAnalyser 0.9.3

- Started a Segmentation (cluster analysis) module:
  - [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
    prepares survey data for cluster analysis: selects the clustering
    variables, handles missing values (listwise deletion, mean/median
    imputation, single `mice` imputation, or keeping them for Gower
    distance), optionally removes respondents above a missing-value
    threshold, rescales the variables (z-standardization or min-max),
    and computes a distance matrix.
  - [`seg_distance()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_distance.md)
    computes distance matrices with a common interface to
    [`factoextra::get_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)
    and [`cluster::daisy()`](https://rdrr.io/pkg/cluster/man/daisy.html)
    (incl. Gower distance).
  - [`seg_clustering_tendency()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_clustering_tendency.md)
    assesses whether the data contains meaningful clusters by comparing
    the actual data with a uniformly distributed random dataset, using
    the (corrected) Hopkins statistic and VAT plots
    ([`factoextra::get_clust_tendency()`](https://rpkgs.datanovia.com/factoextra/reference/get_clust_tendency.html),
    [`factoextra::fviz_dist()`](https://rpkgs.datanovia.com/factoextra/reference/dist.html)).
  - [`seg_optimal_clusters()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_optimal_clusters.md)
    determines the optimal number of clusters with the elbow method
    (WSS), the average silhouette method, the gap statistic and the
    majority vote of 26 NbClust indices, and summarizes their
    suggestions. The individual methods are also available as
    [`seg_nbclust_wss()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_wss.md),
    [`seg_nbclust_silhouette()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_silhouette.md),
    [`seg_nbclust_gap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_gap.md)
    and
    [`seg_nbclust_indices()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_nbclust_indices.md).
  - [`seg_compare_algorithms()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_compare_algorithms.md)
    compares clustering algorithms (hierarchical, k-means, PAM, DIANA,
    CLARA) and numbers of clusters with the internal and stability
    validation measures of the `clValid` package, reports the size of
    the smallest cluster of each solution, and plots all measures with
    ggplot2.
  - [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
    runs a cluster analysis with hierarchical k-means (default),
    k-means, PAM, AGNES, DIANA, fuzzy clustering, model-based
    clustering, DBSCAN or HDBSCAN, for one or several numbers of
    clusters. All methods return a standardized solution (cluster
    assignment renumbered by size, membership degrees/probabilities,
    cluster sizes and centers, the prepared and original data) with a
    cluster plot in the space of the principal components, a dendrogram
    (hierarchical methods) and a heatmap. The method families are also
    available as
    [`seg_cluster_partitioning()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_partitioning.md),
    [`seg_cluster_hkmeans()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hkmeans.md),
    [`seg_cluster_hierarchical()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_hierarchical.md),
    [`seg_cluster_fuzzy()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_fuzzy.md),
    [`seg_cluster_model()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_model.md)
    and
    [`seg_cluster_density()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster_density.md).
  - [`seg_dbscan_eps()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_dbscan_eps.md)
    suggests `eps` for DBSCAN from the k-nearest-neighbor distances.
  - [`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md)
    converts an existing segmentation (e.g. from a previous wave) into
    the same format, so that it can be visualized, profiled and
    validated like new solutions.
  - [`seg_plot_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_cluster.md),
    [`seg_plot_dend()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_dend.md)
    and
    [`seg_plot_heatmap()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_heatmap.md)
    (re)create the plots of a solution, passing further arguments to
    [`factoextra::fviz_cluster()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_cluster.html)
    and
    [`factoextra::fviz_dend()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_dend.html).
    The heatmap is built with ggplot2 for a random sample of
    respondents, with dendrograms of the variables and the respondents
    and a cluster color bar; respondents can be grouped by cluster or
    ordered by a hierarchical clustering.
  - [`seg_plot_centers()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_centers.md)
    plots the profiles of the clusters, i.e. the mean of each clustering
    variable per cluster, as profile lines (default), bars per cluster
    or a heatmap, on the prepared (e.g. z-standardized) or the original
    scale, with the total mean as reference, the variables labelled by
    their variable labels and optionally sorted by how much the clusters
    differ. Every solution of
    [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md),
    its family functions and
    [`seg_as_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_as_cluster.md)
    now includes it as `plots$centers`, customizable with the new
    argument `centers_args`.
  - [`seg_validation()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_validation.md)
    validates one or several cluster solutions (several numbers of
    clusters and/or algorithms) with internal measures (average
    silhouette width, share of negative silhouette widths, Dunn index
    and further statistics of
    [`fpc::cluster.stats()`](https://rdrr.io/pkg/fpc/man/cluster.stats.html))
    and, if a reference grouping is supplied (a vector, a column of the
    original data or an existing segmentation), external measures
    (corrected Rand index, Meila’s variation of information) with cross
    tabulations. It returns silhouette plots
    ([`factoextra::fviz_silhouette()`](https://rpkgs.datanovia.com/factoextra/reference/fviz_silhouette.html))
    and ggplot2 plots of all measures over the number of clusters, and
    reports the best solution per measure.
  - [`seg_plot_silhouette()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_plot_silhouette.md)
    (re)creates the silhouette plot of a solution.
  - [`seg_agreement()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_agreement.md)
    compares the assignments of several cluster solutions computed on
    the same respondents, e.g. different algorithms with the same number
    of clusters. The clusters of each solution are matched to those of a
    reference solution with the Hungarian algorithm
    ([`clue::solve_LSAP()`](https://rdrr.io/pkg/clue/man/solve_LSAP.html)),
    so that cluster numbers are comparable across solutions. It reports
    the pairwise agreement (share of respondents in matched clusters),
    corrected Rand index and variation of information, a heatmap of the
    pairwise agreement, cross tables with the reference, and the matched
    cluster of each respondent in each solution, together with how many
    solutions agree on it. The solutions are also returned with their
    clusters renumbered to match the reference (sizes, centers,
    assignment, memberships and plots), so that their cluster profiles
    can be compared directly. `clue` is suggested.
  - [`predict()`](https://rdrr.io/r/stats/predict.html) assigns new
    respondents (e.g. a new wave) to the clusters of a `seg_cluster`
    solution. The new data is prepared exactly like the original sample:
    missing values are handled with the same strategy (`mice` imputes
    them with a model estimated on the original sample only), and the
    variables are rescaled with the parameters of the original sample.
    Each method uses its own assignment rule: nearest center (k-means,
    hierarchical k-means), nearest medoid (PAM), the linkage of the
    solution (AGNES, DIANA), membership degrees from the `fanny`
    objective (fuzzy), posterior probabilities (`mclust`), and the
    nearest clustered respondent within `eps` or the core distance
    (DBSCAN, HDBSCAN). Alternatives are `rule = "centroid"` and
    `rule = "knn"` (k nearest neighbors). `type = "prob"` returns
    membership probabilities. Distances to the original sample are
    available for all distance measures of
    [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md),
    with the Gower ranges of the original sample.
  - [`seg_prep_data()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_prep_data.md)
    now stores the rescaling parameters (`settings$scaling`), the
    imputation values of mean / median imputation and the `mice`
    arguments.
    [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
    solutions keep them (`prep`), together with the renumbering of the
    clusters (`cluster_map`).
  - Added a segmentation template script (`inst/templates/seg.R`),
    available with `ya_setup_folder_structure(template = "seg")`. It
    follows the segmentation vignette in short with the recommended
    settings (mice imputation, hierarchical k-means): data preparation,
    clustering tendency, number of clusters, validation and robustness
    across algorithms, interpretation with cluster profiles and `eda_`
    functions, export of the data with a labelled segment variable, and
    assignment of new respondents.
- The README now installs the package with
  `remotes::install_github(..., dependencies = TRUE, build_vignettes = TRUE)`,
  so that the vignettes are available offline (`pak` does not build
  vignettes), and gives an overview of the PSM and segmentation modules.
- Updated the package description in `DESCRIPTION`: it now lists the PSM
  and segmentation modules.
- Fixed warnings of `R CMD check`:
  - `scales` and `survey`, which were already used, are now declared in
    Imports. `usethis` and `rstudioapi` (used by
    `ya_setup_folder_structure(make_rproj = TRUE)`) are now suggested;
    [`ya_setup_folder_structure()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_setup_folder_structure.md)
    asks to install them if they are missing.
  - Non-ASCII characters in the R code (e.g. “R²” in the KDA plots and
    messages) are now written as Unicode escapes. The output is
    unchanged.
  - Removed the documentation of the argument `dfSummary_args` from
    [`eda_summary()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_summary.md),
    which does not have this argument.
- [`ya_setup_folder_structure()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_setup_folder_structure.md)
  no longer creates an R project by default (`make_rproj = FALSE`),
  checks `template` against the available templates before creating any
  folder, and supports the new `"seg"` template.
- The `eda_` functions no longer trigger tidyselect’s deprecation
  warning when `vars` is given as `all_of(...)`.
- Set up unit tests with testthat (edition 3), starting with the
  assignment of new respondents (`tests/testthat/test-seg_predict.R`).
- `fpc` is now imported (for
  [`fpc::cluster.stats()`](https://rdrr.io/pkg/fpc/man/cluster.stats.html)).
- `tidyr`, which was already used, is now declared in Imports.
- YouAnalyser now requires R \>= 4.1.0, as the package code uses the
  native pipe `|>` and the function shorthand `\(x)`.
- `mclust` and `dbscan` are suggested for model-based and density-based
  clustering.
- Added `yougov_palette`, an unnamed vector of YouGov colors for plots
  with groups (e.g. clusters), to be used e.g. instead of the `"jco"`
  palette in factoextra.
- `factoextra`, `cluster`, `NbClust` and `clValid` are now imported.
  `ggplot2`, which was already used, is now declared in Imports.
- Added the vignette “5. Segmentation (Cluster Analysis)”, which walks
  through a complete segmentation (data preparation, clustering
  tendency, number of clusters, hierarchical k-means, internal and
  external validation, interpretation with
  [`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md))
  on `sm_synthetic` and `sim_segments`, and explains all metrics with
  common guidelines and their sources.
- Added `sim_segments`, simulated survey data with three well separated
  segments on 20 rating items (and the true segment membership), to
  illustrate the segmentation functions on data with a clear cluster
  structure.
- Added interactive and scriptable descriptive statistics for several
  variables at once (`R/eda_interactive.R`):
  - [`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md)
    opens a Shiny gadget (viewer pane, browser or dialog) to select a
    dataset of the session, variables (searchable by name and variable
    label, or by a pattern such as a whole item battery), a grouping
    variable and an optional weight, and returns plots, descriptive
    statistics, tests of group differences, a detailed, customizable
    `ggstatsplot` plot of a single variable (in the YouGov colors), a
    codebook and the code to reproduce them. Plots are downloaded as
    JPEG with
    [`ya_save_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/ya_save_plot.md).
    If the output of
    [`seg_cluster()`](https://eguizarrosales.github.io/YouAnalyser/reference/seg_cluster.md)
    is supplied, each cluster solution is available as grouping variable
    (e.g. `cluster_k4`).
  - [`eda_describe()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_describe.md)
    computes (optionally weighted) descriptive statistics by group:
    means, standard deviations, standard errors, confidence intervals
    (using Kish’s effective sample size if weighted) and quantiles for
    numeric variables, frequency distributions for categorical
    variables. Variables are treated as numeric if they have at least
    five value labels or distinct values. User-defined missing values
    are set to `NA` first.
  - [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md)
    tests group differences of numeric variables with (weighted) ANOVA
    or Kruskal-Wallis tests (effect sizes from `effectsize`) and
    compares the groups with linear contrasts of a linear model with
    robust (HC3) standard errors via
    [`modelbased::estimate_contrasts()`](https://easystats.github.io/modelbased/reference/estimate_contrasts.html)
    (on the ranks if nonparametric, Holm-adjusted): each group vs. the
    total including the group (default), vs. the rest of the sample,
    vs. the mean of the group means, or all pairs of groups. Categorical
    variables are tested with chi-square tests (Cramer’s V). The tests
    are explained in detail in
    [`?eda_test`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md).
  - [`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md)
    plots a single variable by group with the results of statistical
    tests
    ([`ggstatsplot::ggbetweenstats()`](https://www.indrapatil.com/ggstatsplot/reference/ggbetweenstats.html)
    / `ggbarstats()`) in the YouAnalyser style, with options to hide the
    violin plot, the data points or the boxplot.
  - [`eda_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot.md)
    plots several variables in one plot, labelled with their variable
    labels: horizontal or vertical bar charts of the means with or
    without error bars (CI, SE, SD), boxplots, or stacked bar charts of
    the distributions. Significant differences (tests of
    [`eda_test()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_test.md))
    can be marked: triangles for groups higher / lower than the
    reference (default: the total) or letters of the groups that a group
    significantly exceeds.
- `modelbased`, `effectsize`, `marginaleffects` and `sandwich` are now
  imported (tests of group differences). `shiny`, `bslib`, `DT` (for
  [`eda_explore()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_explore.md))
  and `ggstatsplot` (for
  [`eda_plot_detail()`](https://eguizarrosales.github.io/YouAnalyser/reference/eda_plot_detail.md))
  are suggested.
- Added `sm_synthetic`, a synthetic dataset (based on the 2024 Swissmilk
  “Milch & Umwelt” study) with the 20 nutrition attitude items used for
  the segmentation, the original segment membership
  (`cluster_benchmark`), profiling variables and sociodemographics, for
  use in upcoming segmentation (cluster analysis) functions.

## YouAnalyser 0.9.2

- Added a Price Sensitivity Meter (PSM) module, wrapping the
  `pricesensitivitymeter` package and adding YouGov-specific reporting
  helpers:
  - Re-exported
    [`psm_analysis()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis.html)
    and
    [`psm_analysis_weighted()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis_weighted.html)
    from `pricesensitivitymeter` for the (unweighted and weighted) van
    Westendorp analysis, including the Newton-Miller-Smith (NMS)
    extension.
  - [`psm_design_for_weighted()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_design_for_weighted.md)
    builds an unclustered `survey.design` object from a weight column,
    for use with
    [`psm_analysis_weighted()`](https://max-alletsee.github.io/pricesensitivitymeter/reference/psm_analysis_weighted.html).
  - [`psm_plot()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_plot.md)
    creates the classic van Westendorp price sensitivity plot (with the
    four cumulative distribution curves, indifference and optimal price
    points, and acceptable price range), plus reach and revenue
    optimization plots when the NMS extension was used.
  - [`psm_save_data_for_chart()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_save_data_for_chart.md)
    and
    [`psm_copy_pptx_template()`](https://eguizarrosales.github.io/YouAnalyser/reference/psm_copy_pptx_template.md)
    export PSM results into standardized Excel and PowerPoint templates,
    mirroring the existing KDA reporting workflow.
- Added a new vignette,
  [`vignette("psm")`](https://eguizarrosales.github.io/YouAnalyser/articles/psm.md),
  demonstrating the PSM workflow end to end.
- Added `chm_synthetic`, a synthetic dataset (based on the 2025 CH Media
  Oneplus Streaming Markenstudie) with the four basic van Westendorp
  questions and the two NMS purchase-intention questions, for use in
  examples and the PSM vignette.

## YouAnalyser 0.9.1

- Initial submission.
- First version of the package, introducing:
  - Data processing (`dp_*`) functions for preparing and cleaning survey
    data (e.g., labelling, recoding missing values).
  - Exploratory data analysis (`eda_*`) functions for summarizing and
    visualizing survey data.
  - Key Driver Analysis (`kda_*`) functions, including regression-based
    importance metrics, handling of missing data via imputation, and
    standardized Excel/PowerPoint reporting templates.
