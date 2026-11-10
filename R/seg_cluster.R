# Clustering functions of the segmentation module.
#
# All functions return objects with a standardized structure (class
# `seg_cluster` for one solution, `seg_cluster_set` for several numbers of
# clusters), which are the input for profiling and validation functions.


# ---- Wrapper -----------------------------------------------------------------

#' Cluster analysis (segmentation)
#'
#' Runs a cluster analysis with one of several algorithms and returns the
#' solution in a standardized format, together with visualizations. This is a
#' wrapper around the family functions [seg_cluster_hkmeans()],
#' [seg_cluster_partitioning()], [seg_cluster_hierarchical()],
#' [seg_cluster_fuzzy()], [seg_cluster_model()] and [seg_cluster_density()],
#' which can also be used directly.
#'
#' @details
#' ## Comparison of the methods
#'
#' | Method | Family | k needed | Membership | Cluster shape | Noise / outliers | Speed |
#' |---|---|---|---|---|---|---|
#' | `"hkmeans"` | partitioning (hybrid) | yes | hard | spherical, similar size | sensitive | fast |
#' | `"kmeans"` | partitioning | yes | hard | spherical, similar size | sensitive | fast |
#' | `"pam"` | partitioning | yes | hard | spherical | robust | medium (n < ~5,000) |
#' | `"agnes"` | hierarchical (bottom-up) | yes (cut) | hard | depends on linkage | depends on linkage | medium (n < ~10,000) |
#' | `"diana"` | hierarchical (top-down) | yes (cut) | hard | any | sensitive | slow |
#' | `"fuzzy"` | fuzzy partitioning | yes | soft (degrees) | spherical | sensitive | medium |
#' | `"mclust"` | model-based | optional (BIC) | soft (probabilities) | ellipsoidal, flexible | partly | slow |
#' | `"dbscan"` | density-based | no (`eps`, `min_pts`) | hard + noise | arbitrary | identifies noise | fast |
#' | `"hdbscan"` | density-based | no (`min_pts`) | hard + noise | arbitrary, varying density | identifies noise | fast |
#'
#' ## Which method to use?
#'
#' * **Hierarchical k-means** (`"hkmeans"`, default) combines the strengths of
#'   hierarchical clustering (a good, deterministic starting solution) and
#'   k-means (optimization of the cluster assignment). It is a robust default
#'   for typical survey segmentations based on rating scales.
#' * **k-means** is the classical method; with many random starts (`nstart`)
#'   it gives results similar to hierarchical k-means.
#' * **PAM** (k-medoids) is more robust to outliers and extreme answer
#'   patterns and works with any distance measure (e.g. Manhattan or Gower).
#'   The cluster centers are real respondents (medoids).
#' * **Hierarchical clustering** (AGNES, DIANA) shows how the clusters merge
#'   or split (dendrogram), which helps to understand the structure and to
#'   compare different numbers of clusters. The solution is not optimized
#'   afterwards and respondents cannot change cluster once merged.
#' * **Fuzzy clustering** gives each respondent a membership degree for every
#'   cluster, which shows how clearly respondents belong to a segment.
#' * **Model-based clustering** fits a mixture of multivariate normal
#'   distributions, gives membership probabilities and can choose the number
#'   of clusters and the cluster shapes via BIC. It is statistically
#'   principled but slow and can produce very unequal cluster sizes.
#' * **Density-based clustering** (DBSCAN, HDBSCAN) finds dense regions of
#'   arbitrary shape and labels respondents outside of them as noise. Survey
#'   data with many correlated rating scales rarely contains such regions;
#'   these methods then find a single cluster (or only noise) and are mainly
#'   useful to detect outliers.
#'
#' A good approach is to start with hierarchical k-means, compare the solution
#' with PAM and/or model-based clustering, and validate the candidate
#' solutions (see also [seg_optimal_clusters()] and
#' [seg_compare_algorithms()]).
#'
#' ## Output
#'
#' All methods return an object with the same structure (see "Value"). The
#' clusters are renumbered by size (1 = largest cluster) so that solutions are
#' comparable across methods and numbers of clusters. Noise (density-based
#' methods) is coded as cluster 0.
#'
#' ## Visualizations
#'
#' * `plots$cluster`: the respondents in the space of the first two principal
#'   components ([factoextra::fviz_cluster()]); see [seg_plot_cluster()]. With
#'   many clustering variables, the first two components explain only part of
#'   the variance (shown in the axis labels), so clusters may overlap in the
#'   plot even if they are separated in the full space.
#' * `plots$dend`: the dendrogram of hierarchical methods and hierarchical
#'   k-means ([factoextra::fviz_dend()]); see [seg_plot_dend()].
#' * `plots$heatmap`: a heatmap of a random sample of respondents, sorted by
#'   cluster; see [seg_plot_heatmap()].
#' * `plots$bic`: the BIC of the model-based clustering models
#'   ([factoextra::fviz_mclust()]).
#'
#' @param x The output of [seg_prep_data()] (recommended), or a data frame or
#'   numeric matrix with already prepared clustering variables (no missing
#'   values).
#' @param method Clustering method: `"hkmeans"` (default), `"kmeans"`,
#'   `"pam"`, `"agnes"`, `"diana"`, `"fuzzy"`, `"mclust"`, `"dbscan"` or
#'   `"hdbscan"`. See "Details".
#' @param k Number of clusters. A vector (e.g. `2:6`) returns one solution per
#'   number of clusters. Ignored by the density-based methods. For `"mclust"`,
#'   `NULL` lets the BIC choose the number of clusters (slow).
#' @param ... Further arguments passed to the family function of the method,
#'   e.g. `nstart` for k-means, `linkage` for AGNES, `memb_exp` for fuzzy
#'   clustering or `eps` for DBSCAN.
#' @param plots Logical. Whether to create the plots. Defaults to `TRUE`.
#' @param cluster_plot_args A list of arguments passed to
#'   [factoextra::fviz_cluster()], overriding the defaults (see
#'   [seg_plot_cluster()]), e.g. `list(ellipse.type = "convex")`.
#' @param dend_args A list of arguments passed to [factoextra::fviz_dend()],
#'   overriding the defaults (see [seg_plot_dend()]), e.g.
#'   `list(type = "phylogenic")`.
#' @param heatmap_n Number of respondents randomly sampled for the heatmap.
#'   Defaults to 200.
#' @param seed Random seed. The global random seed is left untouched.
#'   Defaults to 123.
#' @param verbose Logical. Whether to print the results. Defaults to `TRUE`.
#'
#' @returns For a single number of clusters, an object of class `seg_cluster`,
#'   a list with the elements:
#'   * `method`, `family`: the clustering method and its family.
#'   * `k`: the requested number of clusters (`NA` for density-based methods).
#'   * `k_found`: the number of clusters found (excluding noise).
#'   * `cluster`: integer vector with the cluster of each respondent (0 =
#'     noise), in the order of the prepared data.
#'   * `membership`: matrix with the membership degrees (fuzzy) or
#'     probabilities (model-based) of each respondent in each cluster, `NULL`
#'     for the other methods.
#'   * `sizes`: tibble with the size and share of each cluster.
#'   * `centers`: tibble with the mean of each clustering variable per cluster.
#'   * `assignment`: tibble with the respondent identifier, the cluster and
#'     method-specific information (e.g. the highest membership degree).
#'   * `data`, `data_full`, `dist`: the prepared clustering variables, the
#'     original data of the retained respondents and the distance matrix (if
#'     available), as passed on from [seg_prep_data()].
#'   * `fit`: the result of the underlying clustering function.
#'   * `tree`: the hierarchical tree (class `hclust`) for hierarchical methods
#'     and hierarchical k-means, otherwise `NULL`.
#'   * `plots`: list of plots (see "Visualizations").
#'   * `settings`: list of the settings used.
#'
#'   For several numbers of clusters, an object of class `seg_cluster_set`, a
#'   list with the elements `solutions` (named list of `seg_cluster` objects,
#'   e.g. `solutions$k4`), `summary` (tibble with the cluster sizes per
#'   solution), `plot` (the cluster plots of all solutions combined) and
#'   `method`.
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   id = "id",
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#'
#' # Hierarchical k-means with 4 clusters
#' cl <- seg_cluster(prep, k = 4)
#' cl$sizes
#' cl$plots$cluster
#'
#' # PAM for 2 to 5 clusters
#' cl_pam <- seg_cluster(prep, method = "pam", k = 2:5)
#' cl_pam$summary
#'
#' # AGNES with a phylogenic tree
#' cl_agnes <- seg_cluster(
#'   prep,
#'   method = "agnes",
#'   k = 4,
#'   dend_args = list(type = "phylogenic")
#' )
#' }
#'
#' @export
seg_cluster <- function(
  x,
  method = c(
    "hkmeans",
    "kmeans",
    "pam",
    "agnes",
    "diana",
    "fuzzy",
    "mclust",
    "dbscan",
    "hdbscan"
  ),
  k = 4,
  ...,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  method <- rlang::arg_match(method)

  common <- list(
    x = x,
    plots = plots,
    cluster_plot_args = cluster_plot_args,
    dend_args = dend_args,
    heatmap_n = heatmap_n,
    seed = seed,
    verbose = verbose
  )
  dots <- list(...)

  if (method %in% c("dbscan", "hdbscan") && !missing(k)) {
    cli::cli_inform(c(
      "i" = "{.arg k} is ignored by density-based clustering ({.val {method}})."
    ))
  }

  args <- switch(
    method,
    hkmeans = c(common, list(k = k)),
    kmeans = ,
    pam = c(common, list(k = k, method = method)),
    agnes = ,
    diana = c(common, list(k = k, method = method)),
    fuzzy = c(common, list(k = k)),
    mclust = c(common, list(k = k)),
    dbscan = ,
    hdbscan = c(common, list(method = method))
  )

  fun <- switch(
    method,
    hkmeans = seg_cluster_hkmeans,
    kmeans = ,
    pam = seg_cluster_partitioning,
    agnes = ,
    diana = seg_cluster_hierarchical,
    fuzzy = seg_cluster_fuzzy,
    mclust = seg_cluster_model,
    dbscan = ,
    hdbscan = seg_cluster_density
  )

  do.call(fun, c(args, dots))
}


# ---- Partitioning: k-means and PAM -------------------------------------------

#' Partitioning clustering: k-means and PAM
#'
#' Partitions the respondents into `k` clusters with k-means
#' ([stats::kmeans()]) or PAM (partitioning around medoids,
#' [cluster::pam()]).
#'
#' @details
#' ## k-means
#'
#' k-means describes each cluster by its center (the mean of its members) and
#' looks for the partition with the smallest total within-cluster sum of
#' squares, i.e. the most compact clusters:
#'
#' 1. Choose `k` respondents at random as initial cluster centers.
#' 2. Assign each respondent to the nearest center (Euclidean distance).
#' 3. Recompute each center as the mean of its members.
#' 4. Repeat steps 2 and 3 until the assignment no longer changes.
#'
#' The result depends on the random start, so the algorithm is run `nstart`
#' times and the best solution is kept. k-means is fast and simple, but
#' assumes roughly spherical clusters of similar size, is sensitive to
#' outliers and always uses Euclidean distances (the distance measure of
#' [seg_prep_data()] is not used).
#'
#' ## PAM (k-medoids)
#'
#' PAM works like k-means, but each cluster is represented by a *medoid*: the
#' respondent with the smallest average distance to all other members of the
#' cluster.
#'
#' 1. *Build:* select `k` respondents as initial medoids.
#' 2. *Swap:* for each medoid and each non-medoid, check whether swapping them
#'    reduces the sum of the distances of all respondents to their nearest
#'    medoid; carry out the best swap.
#' 3. Repeat step 2 until no swap improves the solution.
#'
#' As it minimizes distances rather than squared distances and uses real
#' respondents as centers, PAM is more robust to outliers and extreme answer
#' patterns than k-means. It works with any distance measure: the distance
#' matrix of [seg_prep_data()] is used (e.g. Manhattan or Gower). PAM is
#' slower than k-means (computation grows with the square of the number of
#' respondents) and deterministic.
#'
#' ## When to use
#'
#' Use k-means for large samples and well-behaved rating scales; prefer
#' [hierarchical k-means][seg_cluster_hkmeans()], which removes the
#' dependence on random starts. Use PAM if the data contains outliers, if you
#' want to use a distance measure other than Euclidean, or if real
#' respondents as "typical members" of each segment are useful (e.g. for
#' personas).
#'
#' @inheritParams seg_cluster
#' @param method `"kmeans"` (default) or `"pam"`.
#' @param nstart Number of random starts for k-means. Defaults to 25.
#' @param iter_max Maximum number of iterations for k-means. Defaults to 50.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' km <- seg_cluster_partitioning(prep, k = 4)
#' pam <- seg_cluster_partitioning(prep, k = 2:5, method = "pam")
#' }
#'
#' @export
seg_cluster_partitioning <- function(
  x,
  k = 4,
  method = c("kmeans", "pam"),
  nstart = 25,
  iter_max = 50,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  method <- rlang::arg_match(method)
  input <- seg_cluster_input(x)
  k_values <- seg_check_k(k, input$data)

  if (method == "kmeans") {
    if (input$distance != "euclidean") {
      cli::cli_inform(c(
        "i" = "k-means always uses Euclidean distances; the {.val {input$distance}} distance is not used."
      ))
    }
    fit_fun <- function(kk) {
      fit <- stats::kmeans(
        input$data,
        centers = kk,
        nstart = nstart,
        iter.max = iter_max
      )
      list(cluster = fit$cluster, fit = fit)
    }
  } else {
    input$dist <- seg_input_dist(input)
    fit_fun <- function(kk) {
      fit <- cluster::pam(input$dist, k = kk, diss = TRUE)
      list(
        cluster = fit$clustering,
        fit = fit,
        extra = tibble::tibble(is_medoid = seq_along(fit$clustering) %in% fit$id.med)
      )
    }
  }

  seg_cluster_run(
    input,
    method = method,
    family = "partitioning",
    k_values = k_values,
    fit_fun = fit_fun,
    settings = list(nstart = nstart, iter_max = iter_max),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = verbose
  )
}


# ---- Hierarchical k-means ----------------------------------------------------

#' Hierarchical k-means clustering
#'
#' Combines hierarchical clustering and k-means
#' ([factoextra::hkmeans()]): the hierarchical solution is used as the
#' starting point for k-means.
#'
#' @details
#' ## Algorithm
#'
#' k-means depends on its random starting centers, and different starts can
#' lead to different solutions. Hierarchical k-means removes this dependence:
#'
#' 1. Compute a hierarchical clustering of the respondents (Ward's method by
#'    default, see [seg_cluster_hierarchical()]) and cut the tree into `k`
#'    clusters.
#' 2. Compute the center (mean) of each of these clusters.
#' 3. Use these centers as starting centers for k-means, which then optimizes
#'    the assignment: respondents can move to the cluster whose center is
#'    closest (which is not possible in pure hierarchical clustering).
#'
#' The result is deterministic, usually at least as good as k-means with many
#' random starts, and combines the "global view" of hierarchical clustering
#' with the optimization of k-means.
#'
#' ## When to use
#'
#' A robust default for survey segmentations based on rating scales, and the
#' default method of [seg_cluster()]. As for k-means, the clusters are assumed
#' to be roughly spherical, and outliers can affect the solution.
#'
#' The dendrogram (`plots$dend`) shows the hierarchical clustering of the
#' first step; its colors show the final cluster that most members of each
#' branch belong to after the k-means step.
#'
#' @inheritParams seg_cluster
#' @param hc_method Agglomeration method for the hierarchical step, passed to
#'   [stats::hclust()]. Defaults to `"ward.D2"`.
#' @param iter_max Maximum number of iterations for k-means. Defaults to 50.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' hk <- seg_cluster_hkmeans(prep, k = 4)
#' hk$plots$dend
#' }
#'
#' @export
seg_cluster_hkmeans <- function(
  x,
  k = 4,
  hc_method = "ward.D2",
  iter_max = 50,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  input <- seg_cluster_input(x)
  k_values <- seg_check_k(k, input$data)

  hc_metric <- if (input$distance %in% seg_get_dist_methods) {
    input$distance
  } else {
    "euclidean"
  }

  fit_fun <- function(kk) {
    fit <- factoextra::hkmeans(
      as.data.frame(input$data),
      k = kk,
      hc.metric = hc_metric,
      hc.method = hc_method,
      iter.max = iter_max
    )
    list(cluster = fit$cluster, fit = fit, tree = fit$hclust)
  }

  seg_cluster_run(
    input,
    method = "hkmeans",
    family = "partitioning",
    k_values = k_values,
    fit_fun = fit_fun,
    settings = list(hc_method = hc_method, hc_metric = hc_metric, iter_max = iter_max),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = verbose
  )
}


# ---- Hierarchical clustering: AGNES and DIANA --------------------------------

#' Hierarchical clustering: AGNES and DIANA
#'
#' Builds a hierarchy of clusters (a tree) with agglomerative
#' ([cluster::agnes()]) or divisive ([cluster::diana()]) hierarchical
#' clustering and cuts it into `k` clusters.
#'
#' @details
#' ## Agglomerative clustering (AGNES, bottom-up)
#'
#' 1. Start with each respondent as its own cluster.
#' 2. Merge the two most similar clusters.
#' 3. Repeat step 2 until all respondents are in one cluster.
#'
#' How the similarity of two clusters is measured is defined by the
#' *linkage*:
#'
#' * `"ward"` (default): merge the two clusters that lead to the smallest
#'   increase in the within-cluster variance. Produces compact clusters of
#'   similar size; the recommended choice for segmentations.
#' * `"complete"`: distance of the two most distant members. Compact clusters,
#'   sensitive to outliers.
#' * `"average"`: average distance of all pairs of members. A compromise, but
#'   often produces one large cluster and a few small ones.
#' * `"single"`: distance of the two closest members. Tends to chain
#'   respondents into long, unbalanced clusters; rarely useful for
#'   segmentations.
#'
#' ## Divisive clustering (DIANA, top-down)
#'
#' 1. Start with all respondents in one cluster.
#' 2. Split the cluster with the largest diameter: the respondent with the
#'    largest average distance to the others starts a "splinter group", and
#'    respondents that are closer to the splinter group than to the rest
#'    follow.
#' 3. Repeat step 2 until each respondent forms its own cluster.
#'
#' DIANA is better at identifying a few large clusters, AGNES at identifying
#' many small ones.
#'
#' ## Dendrogram and cutting the tree
#'
#' The result is a tree (dendrogram), in which the height of each merge
#' reflects the distance between the merged clusters. Cutting the tree at a
#' given height yields `k` clusters; for several values of `k`, the tree is
#' computed only once. Long vertical branches above the cut indicate well
#' separated clusters. The agglomerative / divisive coefficient (in
#' `settings$coefficient`, range 0 to 1) describes the strength of the
#' clustering structure; values close to 1 indicate a clear structure.
#'
#' Both methods use the distance matrix of [seg_prep_data()] and therefore work
#' with any distance measure. Once respondents are merged (or split), they
#' cannot change cluster, so the solution is not optimized afterwards (see
#' [seg_cluster_hkmeans()] for a combination with k-means).
#'
#' ## When to use
#'
#' To explore the structure of the data and how clusters merge or split for
#' different numbers of clusters, and for smaller samples. For a final
#' segmentation, hierarchical k-means usually gives more compact clusters.
#'
#' @inheritParams seg_cluster
#' @param method `"agnes"` (default) or `"diana"`.
#' @param linkage Linkage method for AGNES: `"ward"` (default), `"complete"`,
#'   `"average"`, `"single"`, `"weighted"` or `"gaverage"`. Ignored by DIANA.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' ag <- seg_cluster_hierarchical(prep, k = 2:5)
#' ag$solutions$k4$plots$dend
#' }
#'
#' @export
seg_cluster_hierarchical <- function(
  x,
  k = 4,
  method = c("agnes", "diana"),
  linkage = c("ward", "complete", "average", "single", "weighted", "gaverage"),
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  method <- rlang::arg_match(method)
  linkage <- rlang::arg_match(linkage)
  input <- seg_cluster_input(x)
  k_values <- seg_check_k(k, input$data)
  input$dist <- seg_input_dist(input)

  # The tree is computed only once and cut for each k
  fit <- if (method == "agnes") {
    cluster::agnes(input$dist, diss = TRUE, method = linkage)
  } else {
    cluster::diana(input$dist, diss = TRUE)
  }
  tree <- stats::as.hclust(fit)
  coefficient <- if (method == "agnes") fit$ac else fit$dc

  fit_fun <- function(kk) {
    list(cluster = stats::cutree(tree, kk), fit = fit, tree = tree)
  }

  seg_cluster_run(
    input,
    method = method,
    family = "hierarchical",
    k_values = k_values,
    fit_fun = fit_fun,
    settings = list(
      linkage = if (method == "agnes") linkage else NA_character_,
      coefficient = coefficient
    ),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = verbose
  )
}


# ---- Fuzzy clustering --------------------------------------------------------

#' Fuzzy clustering
#'
#' Assigns each respondent a membership degree for every cluster with fuzzy
#' clustering ([cluster::fanny()]).
#'
#' @details
#' ## Algorithm
#'
#' In "hard" clustering (e.g. k-means), each respondent belongs to exactly
#' one cluster. In fuzzy clustering, each respondent \eqn{i} has a membership
#' degree \eqn{u_{ic}}{u_ic} between 0 and 1 for each cluster \eqn{c}, summing
#' to 1. The algorithm minimizes
#' \deqn{\sum_{c=1}^{k} \frac{\sum_{i,j} u_{ic}^r u_{jc}^r d(i, j)}{2 \sum_j u_{jc}^r}}{sum over clusters c of [sum over i, j of u_ic^r u_jc^r d(i, j)] / [2 sum over j of u_jc^r]}
#' where \eqn{d(i, j)} is the distance between two respondents and \eqn{r} the
#' membership exponent (`memb_exp`): respondents that are close to each other
#' should have high memberships in the same clusters. Each respondent is
#' assigned to the cluster with its highest membership degree (`cluster`); the
#' membership degrees are returned in `membership`, and the highest
#' membership degree of each respondent in `assignment$membership_max`.
#'
#' ## Membership exponent
#'
#' The membership exponent (\eqn{r > 1}) controls the fuzziness: the closer
#' to 1, the crisper the solution; the larger, the fuzzier. The usual default
#' of 2 leads to *complete fuzziness* (all memberships equal to 1/k) for
#' survey data with many clustering variables, which is why the default here
#' is 1.1. Dunn's partition coefficient (in `settings$partition_coefficient`)
#' ranges from 1/k (completely fuzzy) to 1 (crisp); a warning is given if the
#' solution is (almost) completely fuzzy.
#'
#' ## When to use
#'
#' When respondents are expected to belong partly to several segments, or to
#' identify respondents that are clearly assigned (high membership) vs.
#' respondents between segments (e.g. to exclude them when building a typing
#' tool). The distance matrix of [seg_prep_data()] is used.
#'
#' @inheritParams seg_cluster
#' @param memb_exp Membership exponent (> 1). Defaults to 1.1, see "Details".
#' @param max_iter Maximum number of iterations. Defaults to 1000.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' fz <- seg_cluster_fuzzy(prep, k = 4)
#' head(fz$membership)
#' }
#'
#' @export
seg_cluster_fuzzy <- function(
  x,
  k = 4,
  memb_exp = 1.1,
  max_iter = 1000,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  if (!is.numeric(memb_exp) || length(memb_exp) != 1 || memb_exp <= 1) {
    cli::cli_abort("{.arg memb_exp} must be a single number larger than 1.")
  }
  input <- seg_cluster_input(x)
  k_values <- seg_check_k(k, input$data)
  input$dist <- seg_input_dist(input)

  fit_fun <- function(kk) {
    fit <- suppressWarnings(cluster::fanny(
      input$dist,
      k = kk,
      diss = TRUE,
      memb.exp = memb_exp,
      maxit = max_iter
    ))
    pc <- unname(fit$coeff[1])
    if (pc < 1 / kk + 0.05 || fit$k.crisp < kk) {
      cli::cli_warn(c(
        "The fuzzy solution with k = {kk} is (almost) completely fuzzy.",
        "i" = "Partition coefficient: {round(pc, 2)} (completely fuzzy: {round(1 / kk, 2)}); {fit$k.crisp} crisp cluster{?s}.",
        "i" = "Use a smaller {.arg memb_exp} (currently {memb_exp})."
      ))
    }
    membership <- fit$membership
    list(
      cluster = fit$clustering,
      membership = membership,
      fit = fit,
      extra = tibble::tibble(membership_max = apply(membership, 1, max)),
      settings = list(partition_coefficient = pc)
    )
  }

  seg_cluster_run(
    input,
    method = "fuzzy",
    family = "fuzzy",
    k_values = k_values,
    fit_fun = fit_fun,
    settings = list(memb_exp = memb_exp, max_iter = max_iter),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = verbose
  )
}


# ---- Model-based clustering --------------------------------------------------

#' Model-based clustering
#'
#' Fits Gaussian mixture models with [mclust::Mclust()] and assigns each
#' respondent to the cluster with the highest probability. Requires the
#' mclust package.
#'
#' @details
#' ## Algorithm
#'
#' Model-based clustering assumes that the data comes from a mixture of `k`
#' groups, each following a multivariate normal distribution with its own
#' mean and covariance matrix. The covariance matrix determines the shape,
#' volume and orientation of each cluster (ellipsoids). mclust offers 14
#' models, from simple (e.g. `"EII"`: spherical clusters of equal volume) to
#' flexible (e.g. `"VVV"`: ellipsoids of varying shape, volume and
#' orientation).
#'
#' 1. For each model and number of clusters, the parameters are estimated with
#'    the EM algorithm (expectation-maximization), starting from a
#'    hierarchical clustering: the *E-step* computes the probability of each
#'    respondent to belong to each cluster, the *M-step* updates the means and
#'    covariances based on these probabilities.
#' 2. The models are compared with the Bayesian Information Criterion (BIC),
#'    which balances fit and complexity; the model with the highest BIC is
#'    selected (`plots$bic`).
#'
#' Each respondent is assigned to the cluster with the highest probability
#' (`cluster`); the probabilities are returned in `membership`, and the
#' uncertainty of the assignment (1 minus the highest probability) in
#' `assignment$uncertainty`.
#'
#' ## Number of clusters
#'
#' With `k = NULL`, the BIC chooses the number of clusters among 1 to 9 as
#' well. This is statistically principled, but slow (about one minute for
#' 1,400 respondents and 20 variables) and, in large samples, the BIC tends to
#' favor many clusters. With a given `k` (or a vector of values), the best
#' model is chosen for each `k`.
#'
#' ## When to use
#'
#' When clusters of different shapes and sizes are expected, membership
#' probabilities are needed, or the number of clusters should be chosen on
#' statistical grounds. Model-based clustering can produce very unequal
#' cluster sizes, and with many variables the flexible models have many
#' parameters to estimate. It uses the data (not the distance matrix).
#'
#' @inheritParams seg_cluster
#' @param k Number of clusters (or a vector of values). `NULL` lets the BIC
#'   choose among 1 to 9 clusters (slow).
#' @param model_names Covariance models to consider, e.g. `c("EII", "VVV")`.
#'   `NULL` (default) considers all models. See [mclust::mclustModelNames()].
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' if (requireNamespace("mclust", quietly = TRUE)) {
#'   prep <- seg_prep_data(
#'     sm_synthetic,
#'     vars = dplyr::starts_with("F50_0_"),
#'     missing = "mice",
#'     max_missing_prop = 0.2,
#'     verbose = FALSE
#'   )
#'   mc <- seg_cluster_model(prep, k = 4)
#'   mc$plots$bic
#' }
#' }
#'
#' @export
seg_cluster_model <- function(
  x,
  k = 4,
  model_names = NULL,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  rlang::check_installed("mclust", reason = "for model-based clustering.")
  input <- seg_cluster_input(x)
  k_values <- if (is.null(k)) NA_integer_ else seg_check_k(k, input$data)

  fit_fun <- function(kk) {
    g <- if (is.na(kk)) 1:9 else kk
    fit <- seg_mclust(as.matrix(input$data), g, model_names)
    if (is.null(fit)) {
      cli::cli_abort(c(
        "Model-based clustering failed for k = {kk}.",
        "i" = "Try other {.arg model_names} or another number of clusters."
      ))
    }
    membership <- fit$z
    list(
      cluster = fit$classification,
      membership = membership,
      fit = fit,
      extra = tibble::tibble(uncertainty = fit$uncertainty),
      settings = list(model_name = fit$modelName, bic = fit$bic)
    )
  }

  seg_cluster_run(
    input,
    method = "mclust",
    family = "model",
    k_values = k_values,
    fit_fun = fit_fun,
    settings = list(model_names = model_names),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = verbose
  )
}


# ---- Density-based clustering ------------------------------------------------

#' Density-based clustering: DBSCAN and HDBSCAN
#'
#' Finds dense regions of respondents with DBSCAN ([dbscan::dbscan()]) or
#' HDBSCAN ([dbscan::hdbscan()]) and labels respondents outside of them as
#' noise (cluster 0). Requires the dbscan package.
#'
#' @details
#' ## DBSCAN
#'
#' DBSCAN (density-based spatial clustering of applications with noise) does
#' not need the number of clusters, but two parameters: the radius `eps` and
#' the minimum number of points `min_pts`.
#'
#' 1. A respondent is a *core point* if at least `min_pts` respondents
#'    (including itself) lie within the distance `eps`.
#' 2. Core points within `eps` of each other are connected and form a
#'    cluster; respondents within `eps` of a core point (*border points*) are
#'    added to its cluster.
#' 3. All other respondents are *noise* (cluster 0).
#'
#' DBSCAN finds clusters of arbitrary shape and identifies outliers, but uses
#' a single density threshold for all clusters. `min_pts` defaults to twice
#' the number of clustering variables (a common rule of thumb). `eps` defaults
#' to the "knee" of the sorted k-nearest-neighbor distances, see
#' [seg_dbscan_eps()].
#'
#' ## HDBSCAN
#'
#' HDBSCAN (hierarchical DBSCAN) runs DBSCAN for all values of `eps` at once,
#' builds a hierarchy of the resulting clusters and keeps the most stable
#' clusters. It only needs `min_pts` (the minimum cluster size) and can find
#' clusters of varying density. It also returns the probability of each
#' respondent to belong to its cluster (`assignment$membership_prob`) and an
#' outlier score (`assignment$outlier_score`, higher = more outlying).
#'
#' ## When to use
#'
#' For data with dense, well separated groups of arbitrary shape, and to
#' detect outliers. Survey data with many correlated rating scales rarely
#' contains such dense regions: the methods then find a single cluster (with
#' some noise) or only noise. They are therefore mainly useful to identify
#' outliers (e.g. to exclude them before a k-means or PAM segmentation)
#' rather than for the segmentation itself. With many clustering variables,
#' distances become similar for all respondents ("curse of dimensionality"),
#' which makes density-based clustering difficult; consider clustering on a
#' few principal components instead. The distance matrix of [seg_prep_data()]
#' is used if available.
#'
#' @inheritParams seg_cluster
#' @param method `"dbscan"` (default) or `"hdbscan"`.
#' @param eps Radius of the neighborhood for DBSCAN. `NULL` (default) uses the
#'   knee of the k-nearest-neighbor distance plot (see [seg_dbscan_eps()]).
#' @param min_pts Minimum number of respondents in the neighborhood of a core
#'   point (DBSCAN) or minimum cluster size (HDBSCAN). `NULL` (default) uses
#'   twice the number of clustering variables.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' if (requireNamespace("dbscan", quietly = TRUE)) {
#'   prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#'   db <- seg_cluster_density(prep, eps = 0.8, min_pts = 8)
#'   db$sizes
#' }
#' }
#'
#' @export
seg_cluster_density <- function(
  x,
  method = c("dbscan", "hdbscan"),
  eps = NULL,
  min_pts = NULL,
  plots = TRUE,
  cluster_plot_args = list(),
  dend_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  rlang::check_installed("dbscan", reason = "for density-based clustering.")
  method <- rlang::arg_match(method)
  input <- seg_cluster_input(x)

  min_pts <- min_pts %||% (2L * ncol(input$data))
  points <- input$dist %||% as.matrix(input$data)

  if (method == "dbscan" && is.null(eps)) {
    eps <- seg_dbscan_eps(x, min_pts = min_pts)$eps
    if (verbose) {
      cli::cli_inform(c(
        "i" = "{.arg eps} = {round(eps, 3)} (knee of the {min_pts - 1}-nearest-neighbor distances)."
      ))
    }
  }

  fit_fun <- function(kk) {
    if (method == "dbscan") {
      fit <- dbscan::dbscan(points, eps = eps, minPts = min_pts)
      list(cluster = fit$cluster, fit = fit)
    } else {
      fit <- dbscan::hdbscan(points, minPts = min_pts)
      list(
        cluster = fit$cluster,
        fit = fit,
        extra = tibble::tibble(
          membership_prob = fit$membership_prob,
          outlier_score = fit$outlier_scores
        )
      )
    }
  }

  out <- seg_cluster_run(
    input,
    method = method,
    family = "density",
    k_values = NA_integer_,
    fit_fun = fit_fun,
    settings = list(eps = if (method == "dbscan") eps else NA_real_, min_pts = min_pts),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, dend_args, heatmap_n),
    seed = seed,
    verbose = FALSE
  )

  if (out$k_found <= 1) {
    noise <- sum(out$cluster == 0)
    cli::cli_warn(c(
      "{.val {method}} found {out$k_found} cluster{?s} and {noise} noise point{?s}.",
      "i" = "The data contains no clearly separated dense regions (common for survey data).",
      "i" = "Consider other values of {.arg eps} / {.arg min_pts}, or another method."
    ))
  }

  if (verbose) {
    print(out)
  }
  invisible(out)
}


#' Choose eps for DBSCAN: k-nearest-neighbor distance plot
#'
#' Computes the distance of each respondent to its \eqn{k}-th nearest
#' neighbor (\eqn{k} = `min_pts` - 1), sorts these distances and plots them.
#' The suitable value of `eps` for DBSCAN is located at the "knee" of the
#' curve, where the distances start to increase sharply: respondents to the
#' right of the knee are in sparse regions (noise). The knee is determined
#' automatically as the point with the largest distance to the straight line
#' between the first and the last point of the (normalized) curve.
#'
#' @inheritParams seg_cluster_density
#'
#' @returns A list with the elements `eps` (the suggested value), `min_pts`,
#'   `knn` (tibble with the sorted distances) and `plot` (ggplot object).
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' if (requireNamespace("dbscan", quietly = TRUE)) {
#'   prep <- seg_prep_data(iris, vars = -Species, verbose = FALSE)
#'   seg_dbscan_eps(prep, min_pts = 8)$plot
#' }
#' }
#'
#' @export
seg_dbscan_eps <- function(x, min_pts = NULL) {
  rlang::check_installed("dbscan", reason = "to compute nearest-neighbor distances.")
  input <- seg_cluster_input(x)
  min_pts <- min_pts %||% (2L * ncol(input$data))
  points <- input$dist %||% as.matrix(input$data)

  d <- sort(dbscan::kNNdist(points, k = min_pts - 1))
  idx <- seq_along(d)

  # Knee of an increasing, convex curve: largest distance below the diagonal
  xn <- (idx - 1) / (length(idx) - 1)
  yn <- (d - min(d)) / (max(d) - min(d))
  knee <- which.max(xn - yn)
  eps <- d[knee]

  col <- yougov_colors[["Red 1"]]
  knn <- tibble::tibble(rank = idx, distance = d)
  plot <- ggplot2::ggplot(knn, ggplot2::aes(x = .data$rank, y = .data$distance)) +
    ggplot2::geom_line(color = col) +
    ggplot2::geom_hline(yintercept = eps, linetype = 2, color = "grey40") +
    ggplot2::labs(
      title = "k-nearest-neighbor distances",
      subtitle = paste0("Suggested eps = ", round(eps, 3), " | min_pts = ", min_pts),
      x = "Respondents (sorted by distance)",
      y = paste0(min_pts - 1, "-nearest-neighbor distance")
    ) +
    ggplot2::theme_classic()

  list(eps = unname(eps), min_pts = min_pts, knn = knn, plot = plot)
}


# ---- Existing segmentations --------------------------------------------------

#' Convert an existing segmentation to a cluster solution
#'
#' Turns an existing cluster assignment (e.g. a segmentation from a previous
#' wave, or the result of another tool) into a `seg_cluster` object with the
#' same structure as the results of [seg_cluster()]. This makes it possible
#' to visualize, profile and validate it in the same way as new solutions,
#' and to compare them.
#'
#' @inheritParams seg_cluster
#' @param cluster The cluster assignment: either a vector with one value per
#'   respondent in the prepared data, or a single string naming a column of
#'   the original data (`x$data_full`, e.g. `"cluster_benchmark"`).
#' @param name Name of the solution (stored as `method`). Defaults to
#'   `"external"`.
#' @param relabel Logical. Whether to renumber the clusters by size (1 =
#'   largest). Defaults to `FALSE`, which keeps the original codes; their
#'   value labels (if any) are kept in `cluster_labels`.
#'
#' @inherit seg_cluster return
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' benchmark <- seg_as_cluster(prep, "cluster_benchmark", name = "benchmark 2024")
#' benchmark$sizes
#' }
#'
#' @export
seg_as_cluster <- function(
  x,
  cluster,
  name = "external",
  relabel = FALSE,
  plots = TRUE,
  cluster_plot_args = list(),
  heatmap_n = 200,
  seed = 123,
  verbose = TRUE
) {
  input <- seg_cluster_input(x)

  if (rlang::is_string(cluster)) {
    if (!cluster %in% names(input$data_full)) {
      cli::cli_abort("Column {.val {cluster}} not found in the original data.")
    }
    cluster <- input$data_full[[cluster]]
  }
  if (length(cluster) != nrow(input$data)) {
    cli::cli_abort(c(
      "{.arg cluster} must have one value per respondent of the prepared data.",
      "x" = "Expected {nrow(input$data)} values, got {length(cluster)}."
    ))
  }
  if (anyNA(cluster)) {
    cli::cli_abort("{.arg cluster} must not contain missing values.")
  }

  labels <- attr(cluster, "labels", exact = TRUE)
  cluster_codes <- as.integer(haven::zap_labels(cluster))
  cluster_labels <- if (!is.null(labels)) {
    stats::setNames(names(labels), labels)
  } else {
    NULL
  }

  fit_fun <- function(kk) {
    list(cluster = cluster_codes, fit = NULL)
  }

  seg_cluster_run(
    input,
    method = name,
    family = "external",
    k_values = length(unique(cluster_codes[cluster_codes != 0])),
    fit_fun = fit_fun,
    settings = list(relabel = relabel),
    plot_opts = seg_plot_opts(plots, cluster_plot_args, list(), heatmap_n),
    seed = seed,
    verbose = verbose,
    relabel = relabel,
    cluster_labels = cluster_labels
  )
}


# ---- Plots -------------------------------------------------------------------

#' Plot a cluster solution in the space of the principal components
#'
#' Plots the respondents in the space of the first two principal components,
#' colored by cluster, using [factoextra::fviz_cluster()]. The defaults depend
#' on the clustering family:
#'
#' * partitioning, fuzzy and external solutions: `ellipse.type = "euclid"`
#'   (circles around the cluster centers) and `star.plot = TRUE` (segments
#'   from each respondent to its cluster center),
#' * hierarchical clustering: `ellipse.type = "convex"` (convex hulls) and
#'   `show.clust.cent = FALSE`,
#' * model-based clustering: `ellipse.type = "norm"` (normal ellipses),
#' * density-based clustering: convex hulls, noise in grey.
#'
#' The principal components are computed on the prepared clustering variables
#' (`stand = FALSE`, as the variables are already rescaled by
#' [seg_prep_data()]). With many clustering variables, the first two
#' components explain only part of the variance (see the axis labels).
#'
#' @param object A `seg_cluster` object, e.g. from [seg_cluster()].
#' @param ... Arguments passed to [factoextra::fviz_cluster()], overriding the
#'   defaults.
#'
#' @returns A ggplot object.
#'
#' @family clustering
#'
#' @export
seg_plot_cluster <- function(object, ...) {
  seg_check_cluster_object(object)
  user_args <- list(...)

  data <- as.data.frame(object$data)
  cl <- object$cluster
  n_cl <- length(setdiff(unique(cl), 0))

  base <- list(
    stand = FALSE,
    geom = "point",
    pointsize = 1,
    palette = seg_palette(n_cl),
    ggtheme = ggplot2::theme_classic(),
    main = seg_solution_title(object)
  )

  family_args <- switch(
    object$family,
    hierarchical = list(ellipse.type = "convex", show.clust.cent = FALSE),
    model = list(ellipse.type = "norm"),
    density = list(
      ellipse.type = "convex",
      show.clust.cent = FALSE,
      outlier.color = "grey60",
      outlier.shape = 19
    ),
    list(ellipse.type = "euclid", star.plot = TRUE)
  )

  object_arg <- if (object$family == "density") {
    # Treated like a dbscan result, so that cluster 0 is shown as noise
    list(object = structure(list(cluster = cl), class = "dbscan"), data = data)
  } else {
    list(object = list(data = data, cluster = cl))
  }

  args <- utils::modifyList(c(object_arg, base, family_args), user_args)
  do.call(factoextra::fviz_cluster, args)
}


#' Plot the dendrogram of a hierarchical cluster solution
#'
#' Plots the dendrogram of hierarchical clustering or hierarchical k-means
#' with [factoextra::fviz_dend()], colored by cluster.
#'
#' Dendrograms of all respondents are slow to draw and unreadable for large
#' samples. Therefore, only the upper part of the tree is plotted, with
#' `max_leaves` leaves (each leaf being a small group of respondents). The
#' structure of the upper part, which determines the clusters, is unchanged.
#' The colors show the clusters of the solution (for hierarchical k-means:
#' the final cluster of most members of each branch).
#'
#' @inheritParams seg_plot_cluster
#' @param max_leaves Maximum number of leaves shown. Defaults to 100.
#' @param ... Arguments passed to [factoextra::fviz_dend()], overriding the
#'   defaults, e.g. `type = "phylogenic"` or `type = "circular"`,
#'   `rect = TRUE` or `horiz = TRUE`.
#'
#' @returns A ggplot object, or `NULL` (with a message) for solutions without
#'   a tree.
#'
#' @family clustering
#'
#' @export
seg_plot_dend <- function(object, max_leaves = 100, ...) {
  seg_check_cluster_object(object)
  tree <- object$tree
  if (is.null(tree)) {
    cli::cli_inform(
      "No dendrogram available for {.val {object$method}} (not a hierarchical method)."
    )
    return(invisible(NULL))
  }
  user_args <- list(...)
  k <- object$k_found

  # Colors: final cluster of most members of each branch of the cut tree,
  # in the order in which the branches appear in the dendrogram
  cut <- stats::cutree(tree, k)
  branches <- unique(cut[tree$order])
  branch_cluster <- purrr::map_int(branches, \(b) {
    tab <- table(object$cluster[cut == b])
    as.integer(names(tab)[which.max(tab)])
  })
  k_colors <- seg_palette(max(object$cluster))[branch_cluster]

  # Upper part of the tree with at most max_leaves leaves
  dend <- stats::as.dendrogram(tree)
  n_leaves <- length(tree$order)
  if (n_leaves > max_leaves) {
    heights <- sort(tree$height, decreasing = TRUE)
    h <- mean(heights[c(max_leaves - 1, max_leaves)])
    dend <- cut(dend, h = h)$upper
  }

  base <- list(
    x = dend,
    k = k,
    k_colors = k_colors,
    show_labels = FALSE,
    rect = FALSE,
    lwd = 0.5,
    main = paste0("Dendrogram: ", seg_solution_title(object)),
    ggtheme = ggplot2::theme_classic()
  )

  args <- utils::modifyList(base, user_args)
  do.call(factoextra::fviz_dend, args)
}


#' Heatmap of a cluster solution
#'
#' Plots the prepared clustering variables of a random sample of respondents
#' as a heatmap with dendrograms, built with ggplot2:
#'
#' * **Cells:** the values of the prepared clustering variables (e.g.
#'   z-standardized), from low (blue) to high (red). Extreme values are capped
#'   at the 1st and 99th percentile, so that a few outliers do not dominate
#'   the colors.
#' * **Top dendrogram:** hierarchical clustering of the variables (Ward's
#'   method), so that variables with similar answer patterns are next to each
#'   other.
#' * **Left dendrogram and color bar:** the respondents and their cluster.
#'
#' With `row_order = "cluster"` (default), respondents are grouped by
#' cluster; within each cluster, they are ordered by a hierarchical
#' clustering, whose dendrogram is drawn in the color of the cluster. Clear
#' blocks of color within a cluster indicate a homogeneous cluster with a
#' distinct profile.
#'
#' With `row_order = "dendrogram"`, the respondents are ordered by a
#' hierarchical clustering of the whole sample (Ward's method), as in a
#' classical heatmap, independently of the cluster solution. The color bar
#' then shows whether the clusters of the solution correspond to the
#' structure found by the hierarchical clustering; branches containing
#' respondents of a single cluster are drawn in its color.
#'
#' @inheritParams seg_plot_cluster
#' @param n Number of respondents sampled (proportionally to the cluster
#'   sizes, at least 2 per cluster). Defaults to 200. `NULL` uses all
#'   respondents.
#' @param row_order How to order the respondents: `"cluster"` (default) or
#'   `"dendrogram"`, see "Details".
#' @param seed Random seed for the sample. The global random seed is left
#'   untouched. Defaults to 123.
#'
#' @returns A ggplot object.
#'
#' @family clustering
#'
#' @examples
#' \donttest{
#' prep <- seg_prep_data(
#'   sm_synthetic,
#'   vars = dplyr::starts_with("F50_0_"),
#'   missing = "mice",
#'   max_missing_prop = 0.2,
#'   verbose = FALSE
#' )
#' cl <- seg_cluster(prep, k = 4, plots = FALSE, verbose = FALSE)
#' seg_plot_heatmap(cl)
#' seg_plot_heatmap(cl, n = 300, row_order = "dendrogram")
#' }
#'
#' @export
seg_plot_heatmap <- function(
  object,
  n = 200,
  row_order = c("cluster", "dendrogram"),
  seed = 123
) {
  seg_check_cluster_object(object)
  row_order <- rlang::arg_match(row_order)

  data <- as.matrix(object$data)
  cl <- object$cluster
  n_total <- nrow(data)

  # ---- Sample of respondents (proportional to the cluster sizes) ----

  rows <- if (is.null(n) || n >= n_total) {
    seq_len(n_total)
  } else {
    seg_with_seed(seed, {
      sort(unlist(lapply(split(seq_len(n_total), cl), \(idx) {
        size <- max(2, round(n * length(idx) / n_total))
        if (length(idx) <= size) idx else sample(idx, size)
      })))
    })
  }
  d <- data[rows, , drop = FALSE]
  cl_s <- cl[rows]
  m <- nrow(d)
  p <- ncol(d)

  # ---- Dendrograms (tree coordinates) ----

  row_tree <- if (row_order == "cluster") {
    seg_dend_by_group(d, cl_s)
  } else {
    seg_dend_segments(stats::hclust(stats::dist(d), method = "ward.D2"), cl_s)
  }
  row_pos <- integer(m)
  row_pos[row_tree$order] <- seq_len(m)

  col_tree <- if (p > 2) {
    seg_dend_segments(stats::hclust(stats::dist(t(d)), method = "ward.D2"))
  } else {
    list(order = seq_len(p), segments = NULL, height = 1)
  }
  col_pos <- integer(p)
  col_pos[col_tree$order] <- seq_len(p)

  # ---- Layout (plot coordinates) ----
  # Heatmap cells: x = 1..p (variables), y = 1..m (respondents, first row on
  # top). The dendrograms and the cluster bar are drawn around the cells.

  gap_x <- 0.15
  bar_w <- max(0.5, 0.04 * p)
  left_w <- 0.25 * p
  gap_y <- 0.01 * m
  top_h <- 0.2 * m

  bar_right <- 0.5 - gap_x
  bar_left <- bar_right - bar_w
  dend_right <- bar_left - gap_x

  flip <- function(pos) m + 1 - pos

  # Heatmap values, capped at the 1st and 99th percentile
  limits <- stats::quantile(d, c(0.01, 0.99), names = FALSE)
  if (limits[1] == limits[2]) {
    limits <- range(d)
  }
  tiles <- tibble::tibble(
    x = rep(col_pos, each = m),
    y = rep(flip(row_pos), times = p),
    value = pmin(pmax(as.vector(d), limits[1]), limits[2])
  )

  # Cluster bar
  codes <- sort(unique(cl_s[cl_s != 0]))
  if (any(cl_s == 0)) {
    codes <- c(codes, 0L)
  }
  palette <- seg_palette(max(c(codes, 1)))
  code_colors <- stats::setNames(
    ifelse(codes == 0, "grey60", palette[pmax(codes, 1)]),
    codes
  )
  bar <- tibble::tibble(
    xmin = bar_left,
    xmax = bar_right,
    ymin = flip(row_pos) - 0.5,
    ymax = flip(row_pos) + 0.5,
    color = unname(code_colors[as.character(cl_s)])
  )

  # Row dendrogram: leaves at the cluster bar, root on the left
  row_max <- max(row_tree$height, .Machine$double.eps)
  row_seg <- row_tree$segments |>
    dplyr::mutate(
      x_plot = dend_right - .data$y / row_max * left_w,
      xend_plot = dend_right - .data$yend / row_max * left_w,
      y_plot = flip(.data$x),
      yend_plot = flip(.data$xend)
    )

  # Column dendrogram: leaves above the cells, root on top
  col_seg <- NULL
  if (!is.null(col_tree$segments)) {
    col_max <- max(col_tree$height, .Machine$double.eps)
    col_seg <- col_tree$segments |>
      dplyr::mutate(
        y = m + 0.5 + gap_y + .data$y / col_max * top_h,
        yend = m + 0.5 + gap_y + .data$yend / col_max * top_h
      )
  }

  # Colors of the dendrogram branches: cluster colors, grey for branches
  # mixing several clusters and for the connections between clusters
  segment_colors <- c(code_colors, mixed = "grey55", join = "grey55")
  cluster_names <- seg_cluster_names(object, codes)

  # ---- Plot ----

  plot <- ggplot2::ggplot() +
    ggplot2::geom_raster(
      data = tiles,
      ggplot2::aes(x = .data$x, y = .data$y, fill = .data$value)
    ) +
    ggplot2::geom_rect(
      data = bar,
      ggplot2::aes(
        xmin = .data$xmin,
        xmax = .data$xmax,
        ymin = .data$ymin,
        ymax = .data$ymax
      ),
      fill = bar$color
    ) +
    ggplot2::geom_segment(
      data = row_seg,
      ggplot2::aes(
        x = .data$x_plot,
        y = .data$y_plot,
        xend = .data$xend_plot,
        yend = .data$yend_plot,
        color = .data$group
      ),
      linewidth = 0.3
    )

  if (!is.null(col_seg)) {
    plot <- plot +
      ggplot2::geom_segment(
        data = col_seg,
        ggplot2::aes(
          x = .data$x,
          y = .data$y,
          xend = .data$xend,
          yend = .data$yend
        ),
        color = "grey40",
        linewidth = 0.3
      )
  }

  plot +
    ggplot2::scale_fill_gradient2(
      low = yougov_colors[["Blue 1"]],
      mid = "white",
      high = yougov_colors[["Red 1"]],
      midpoint = stats::median(d),
      limits = limits,
      name = "Value"
    ) +
    ggplot2::scale_color_manual(
      values = segment_colors,
      breaks = as.character(codes),
      labels = cluster_names,
      name = "Cluster"
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_len(p),
      labels = colnames(d)[col_tree$order],
      expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::coord_cartesian(
      xlim = c(dend_right - left_w, p + 0.5),
      ylim = c(0.5, m + 0.5 + gap_y + top_h),
      clip = "off"
    ) +
    ggplot2::labs(
      title = paste0("Heatmap: ", seg_solution_title(object)),
      subtitle = paste0(
        if (m < n_total) paste0("Random sample of ", m) else paste0("All ", m),
        " respondents | ",
        if (row_order == "cluster") {
          "ordered by cluster"
        } else {
          "ordered by hierarchical clustering"
        }
      ),
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = 90,
        hjust = 1,
        vjust = 0.5,
        size = 8,
        margin = ggplot2::margin(t = 2)
      ),
      plot.title = ggplot2::element_text(face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10),
      legend.position = "right"
    ) +
    ggplot2::guides(
      color = ggplot2::guide_legend(
        override.aes = list(linewidth = 3),
        order = 1
      ),
      fill = ggplot2::guide_colorbar(order = 2)
    )
}


# Segments of a dendrogram (from an hclust object) in tree coordinates:
# x = position of the leaves (1..n in the order of the tree), y = height.
# If groups are given, each branch gets the group of its leaves, or "mixed".
seg_dend_segments <- function(hc, groups = NULL) {
  n <- length(hc$order)
  pos <- integer(n)
  pos[hc$order] <- seq_len(n)
  leaf_group <- if (is.null(groups)) rep("mixed", n) else as.character(groups)

  merges <- hc$merge
  n_merge <- nrow(merges)
  node_x <- numeric(n_merge)
  node_group <- character(n_merge)

  # Three segments per merge: two vertical, one horizontal
  seg <- matrix(NA_real_, nrow = 3 * n_merge, ncol = 4)
  seg_group <- character(3 * n_merge)

  for (j in seq_len(n_merge)) {
    h <- hc$height[j]
    child_x <- numeric(2)
    child_h <- numeric(2)
    child_group <- character(2)
    for (s in 1:2) {
      child <- merges[j, s]
      if (child < 0) {
        child_x[s] <- pos[-child]
        child_h[s] <- 0
        child_group[s] <- leaf_group[-child]
      } else {
        child_x[s] <- node_x[child]
        child_h[s] <- hc$height[child]
        child_group[s] <- node_group[child]
      }
      seg[3 * (j - 1) + s, ] <- c(child_x[s], child_h[s], child_x[s], h)
      seg_group[3 * (j - 1) + s] <- child_group[s]
    }
    node_x[j] <- mean(child_x)
    node_group[j] <- if (child_group[1] == child_group[2]) {
      child_group[1]
    } else {
      "mixed"
    }
    seg[3 * j, ] <- c(child_x[1], h, child_x[2], h)
    seg_group[3 * j] <- node_group[j]
  }

  list(
    segments = tibble::tibble(
      x = seg[, 1],
      y = seg[, 2],
      xend = seg[, 3],
      yend = seg[, 4],
      group = seg_group
    ),
    order = hc$order,
    height = max(hc$height),
    root_x = node_x[n_merge],
    root_h = hc$height[n_merge]
  )
}

# Dendrogram with the respondents grouped by cluster: one hierarchical
# clustering per cluster, placed side by side and joined at the top
seg_dend_by_group <- function(d, groups) {
  codes <- sort(unique(groups[groups != 0]))
  if (any(groups == 0)) {
    codes <- c(codes, 0L)
  }

  offset <- 0
  order <- integer(0)
  segments <- list()
  roots <- tibble::tibble(x = numeric(0), h = numeric(0))

  for (g in codes) {
    idx <- which(groups == g)
    if (length(idx) >= 2) {
      hc <- stats::hclust(stats::dist(d[idx, , drop = FALSE]), method = "ward.D2")
      tree <- seg_dend_segments(hc, rep(g, length(idx)))
      segments[[length(segments) + 1]] <- tree$segments |>
        dplyr::mutate(x = .data$x + offset, xend = .data$xend + offset)
      order <- c(order, idx[hc$order])
      roots <- dplyr::bind_rows(
        roots,
        tibble::tibble(x = tree$root_x + offset, h = tree$root_h)
      )
    } else {
      order <- c(order, idx)
      roots <- dplyr::bind_rows(roots, tibble::tibble(x = offset + 1, h = 0))
    }
    offset <- offset + length(idx)
  }

  height <- max(roots$h, 0)
  if (nrow(roots) > 1) {
    top <- if (height > 0) height * 1.15 else 1
    segments[[length(segments) + 1]] <- tibble::tibble(
      x = c(roots$x, min(roots$x)),
      y = c(roots$h, top),
      xend = c(roots$x, max(roots$x)),
      yend = c(rep(top, nrow(roots)), top),
      group = "join"
    )
    height <- top
  }

  list(
    segments = dplyr::bind_rows(segments),
    order = order,
    height = height
  )
}


# ---- Print methods -----------------------------------------------------------

#' @export
print.seg_cluster <- function(x, ...) {
  cli::cli_h2("Cluster solution: {seg_solution_title(x)}")
  s <- x$sizes
  cluster_txt <- ifelse(
    s$cluster == 0,
    "Noise",
    paste("Cluster", s$cluster)
  )
  if (!is.null(x$cluster_labels)) {
    lbl <- x$cluster_labels[as.character(s$cluster)]
    cluster_txt <- ifelse(is.na(lbl), cluster_txt, paste0(cluster_txt, " (", lbl, ")"))
  }
  cli::cli_ul(paste0(
    cluster_txt,
    ": n = ",
    s$n,
    " (",
    round(100 * s$share),
    "%)"
  ))
  if (length(x$plots) > 0) {
    cli::cli_text("{.emph Plots: {.code {paste0('$plots$', names(x$plots))}}}")
  }
  invisible(x)
}

#' @export
print.seg_cluster_set <- function(x, ...) {
  cli::cli_h2("Cluster solutions: {x$method}")
  s <- x$summary
  cli::cli_ul(paste0(
    "k = ",
    s$k,
    ": ",
    s$sizes,
    " (smallest: ",
    round(100 * s$smallest_share),
    "%)"
  ))
  cli::cli_text(
    "{.emph Solutions: {.code {paste0('$solutions$', names(x$solutions))}}}"
  )
  invisible(x)
}


# ---- Internal helpers --------------------------------------------------------

# Input of the clustering functions: prepared data, distance matrix (if
# available), identifiers and original data of the retained respondents
seg_cluster_input <- function(x) {
  input <- seg_extract_input(x)
  if (inherits(x, "seg_prep")) {
    id <- x$settings$id
    input$data_full <- x$data_full
    input$id_name <- id %||% "row"
    input$ids <- if (is.null(id)) {
      x$row_index
    } else {
      as.vector(haven::zap_labels(x$data_full[[id]]))
    }
  } else {
    input$data_full <- tibble::as_tibble(as.data.frame(x))
    input$id_name <- "row"
    input$ids <- seq_len(nrow(input$data))
  }
  input
}

# Distance matrix of the input (computed if not available)
seg_input_dist <- function(input) {
  input$dist %||%
    seg_distance(
      input$data,
      distance = input$distance,
      distance_engine = input$distance_engine,
      daisy_args = input$daisy_args
    )
}

seg_check_k <- function(k, data) {
  if (
    !is.numeric(k) ||
      length(k) == 0 ||
      anyNA(k) ||
      any(k != round(k)) ||
      any(k < 1) ||
      any(k >= nrow(data))
  ) {
    cli::cli_abort(
      "{.arg k} must contain integers between 1 and the number of respondents - 1."
    )
  }
  sort(unique(as.integer(k)))
}

seg_plot_opts <- function(plots, cluster_plot_args, dend_args, heatmap_n) {
  list(
    plots = plots,
    cluster_plot_args = cluster_plot_args,
    dend_args = dend_args,
    heatmap_n = heatmap_n
  )
}

seg_palette <- function(n) {
  rep_len(yougov_palette, max(n, 1))
}

# Run a clustering for each k and build the standardized output
seg_cluster_run <- function(
  input,
  method,
  family,
  k_values,
  fit_fun,
  settings,
  plot_opts,
  seed,
  verbose,
  relabel = TRUE,
  cluster_labels = NULL
) {
  solutions <- purrr::map(k_values, \(kk) {
    res <- seg_with_seed(seed, fit_fun(kk))
    obj <- seg_new_cluster(
      input,
      method = method,
      family = family,
      k = kk,
      res = res,
      settings = c(settings, res$settings, list(seed = seed)),
      relabel = relabel,
      cluster_labels = cluster_labels
    )
    if (isTRUE(plot_opts$plots)) {
      obj$plots <- seg_cluster_plots(obj, plot_opts, seed)
    }
    obj
  })

  if (length(solutions) == 1) {
    out <- solutions[[1]]
  } else {
    names(solutions) <- paste0("k", k_values)
    summary_tbl <- purrr::map(solutions, \(s) {
      valid <- s$sizes[s$sizes$cluster != 0, ]
      tibble::tibble(
        k = s$k,
        k_found = s$k_found,
        sizes = paste(valid$n, collapse = " / "),
        smallest_share = min(valid$share),
        noise = sum(s$cluster == 0)
      )
    }) |>
      purrr::list_rbind()

    cluster_plots <- purrr::map(solutions, \(s) s$plots$cluster) |>
      purrr::compact()
    combined <- if (length(cluster_plots) > 0) {
      do.call(
        see::plots,
        c(unname(cluster_plots), list(n_columns = min(3, length(cluster_plots))))
      )
    } else {
      NULL
    }

    out <- structure(
      list(
        solutions = solutions,
        summary = summary_tbl,
        plot = combined,
        method = method
      ),
      class = c("seg_cluster_set", "list")
    )
  }

  if (verbose) {
    print(out)
  }
  invisible(out)
}

# Build a standardized seg_cluster object from a clustering result
seg_new_cluster <- function(
  input,
  method,
  family,
  k,
  res,
  settings,
  relabel = TRUE,
  cluster_labels = NULL
) {
  cluster <- as.integer(res$cluster)
  membership <- res$membership

  if (relabel) {
    relabelled <- seg_relabel(cluster, membership)
    cluster <- relabelled$cluster
    membership <- relabelled$membership
    if (!is.null(cluster_labels)) {
      new_codes <- relabelled$map[names(cluster_labels)]
      cluster_labels <- stats::setNames(
        cluster_labels[!is.na(new_codes)],
        new_codes[!is.na(new_codes)]
      )
    }
  } else if (!is.null(membership)) {
    colnames(membership) <- paste0("cluster_", seq_len(ncol(membership)))
  }

  data <- input$data
  k_found <- length(setdiff(unique(cluster), 0))

  # Computed outside of tibble(): inside, `cluster` would refer to the column
  tab <- table(cluster)
  n_total <- length(cluster)
  sizes <- tibble::tibble(
    cluster = as.integer(names(tab)),
    n = as.integer(tab),
    share = as.numeric(tab) / n_total
  ) |>
    dplyr::arrange(.data$cluster == 0, .data$cluster)

  centers <- data |>
    dplyr::mutate(cluster = cluster) |>
    dplyr::filter(.data$cluster != 0) |>
    dplyr::summarise(
      dplyr::across(dplyr::everything(), mean),
      .by = "cluster"
    ) |>
    dplyr::arrange(.data$cluster)

  assignment <- tibble::tibble(
    !!input$id_name := input$ids,
    cluster = cluster
  )
  if (!is.null(res$extra)) {
    assignment <- dplyr::bind_cols(assignment, res$extra)
  }

  structure(
    list(
      method = method,
      family = family,
      k = if (is.na(k)) NA_integer_ else as.integer(k),
      k_found = k_found,
      cluster = cluster,
      membership = membership,
      sizes = sizes,
      centers = centers,
      assignment = assignment,
      cluster_labels = cluster_labels,
      data = data,
      data_full = input$data_full,
      dist = input$dist,
      fit = res$fit,
      tree = res$tree,
      plots = list(),
      settings = c(
        list(
          distance = input$distance,
          distance_engine = input$distance_engine
        ),
        settings
      )
    ),
    class = c("seg_cluster", "list")
  )
}

# Renumber clusters by size (1 = largest), keeping 0 (noise); reorder the
# membership columns accordingly
seg_relabel <- function(cluster, membership = NULL) {
  valid <- cluster[cluster != 0]
  tab <- table(valid)
  old <- as.integer(names(tab))[order(-as.integer(tab), as.integer(names(tab)))]
  map <- stats::setNames(seq_along(old), old)

  new <- ifelse(cluster == 0, 0L, unname(map[as.character(cluster)]))

  if (!is.null(membership)) {
    n_col <- ncol(membership)
    col_order <- c(old[old <= n_col], setdiff(seq_len(n_col), old))
    membership <- membership[, col_order, drop = FALSE]
    colnames(membership) <- paste0("cluster_", seq_len(n_col))
  }

  list(cluster = as.integer(new), membership = membership, map = map)
}

seg_cluster_plots <- function(obj, plot_opts, seed) {
  plots <- list(
    cluster = do.call(seg_plot_cluster, c(list(obj), plot_opts$cluster_plot_args))
  )
  if (!is.null(obj$tree)) {
    plots$dend <- do.call(seg_plot_dend, c(list(obj), plot_opts$dend_args))
  }
  plots$heatmap <- seg_plot_heatmap(obj, n = plot_opts$heatmap_n, seed = seed)
  if (obj$method == "mclust") {
    plots$bic <- seg_plot_mclust_bic(obj$fit)
  }
  plots
}

# BIC of the mclust models: line chart over k (factoextra), or bar chart of
# the covariance models if only one k was fitted
seg_plot_mclust_bic <- function(fit) {
  bic <- fit$BIC
  if (nrow(bic) > 1) {
    return(
      factoextra::fviz_mclust(fit, what = "BIC", palette = seg_palette(14)) +
        ggplot2::labs(title = "Model selection (BIC)")
    )
  }
  values <- tibble::tibble(
    model = colnames(bic),
    bic = as.numeric(bic[1, ])
  ) |>
    dplyr::filter(!is.na(.data$bic)) |>
    dplyr::mutate(
      selected = .data$model == fit$modelName,
      model = stats::reorder(.data$model, .data$bic)
    )

  # Dot chart (BIC values are large negative numbers, unsuitable for bars)
  ggplot2::ggplot(
    values,
    ggplot2::aes(x = .data$bic, y = .data$model, color = .data$selected)
  ) +
    ggplot2::geom_point(size = 3) +
    ggplot2::scale_color_manual(
      values = c(`TRUE` = yougov_colors[["Red 1"]], `FALSE` = "grey60"),
      guide = "none"
    ) +
    ggplot2::labs(
      title = "Model selection (BIC)",
      subtitle = paste0(
        "k = ", fit$G, " | selected model: ", fit$modelName, " (highest BIC)"
      ),
      x = "BIC",
      y = "Covariance model"
    ) +
    ggplot2::theme_classic()
}

seg_solution_title <- function(object) {
  method_txt <- switch(
    object$method,
    hkmeans = "Hierarchical k-means",
    kmeans = "k-means",
    pam = "PAM",
    agnes = "AGNES",
    diana = "DIANA",
    fuzzy = "Fuzzy clustering",
    mclust = "Model-based clustering",
    dbscan = "DBSCAN",
    hdbscan = "HDBSCAN",
    object$method
  )
  if (object$method == "mclust" && !is.null(object$fit$modelName)) {
    method_txt <- paste0(method_txt, " (", object$fit$modelName, ")")
  }
  paste0(method_txt, ", k = ", object$k_found)
}

seg_cluster_names <- function(object, cluster) {
  out <- ifelse(cluster == 0, "Noise", paste("Cluster", cluster))
  if (!is.null(object$cluster_labels)) {
    lbl <- object$cluster_labels[as.character(cluster)]
    out <- ifelse(is.na(lbl), out, paste0(out, ": ", lbl))
  }
  out
}

seg_check_cluster_object <- function(object) {
  if (!inherits(object, "seg_cluster")) {
    cli::cli_abort(c(
      "{.arg object} must be a single cluster solution ({.cls seg_cluster}).",
      "i" = "For several solutions, use e.g. {.code object$solutions$k4}."
    ))
  }
  invisible(TRUE)
}

# mclust::Mclust() looks up mclustBIC() in the calling environment, which
# fails if mclust is not attached: provide it locally
seg_mclust <- function(data, G, model_names) {
  mclustBIC <- mclust::mclustBIC
  mclust::Mclust(data, G = G, modelNames = model_names, verbose = FALSE)
}
