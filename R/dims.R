#' Calculate principal components using irlba
#'
#' @param fce fce object
#' @param expt one of either sce (rna data, the default) or fsce (functional
#'   data)
#' @param assay select which assay data to use for PCA, defaults to logcounts
#'   (i.e. log normalized data)
#' @param genes vector of genes to include in PCA, defaults to all genes
#' @param n_pcs number of principle components to return
#' @param scale perform PCA on input on scaled data, defaults to TRUE
#'
#' @return fce object with PCA values added to reducedDims
#'
#' @export
calc_pca <- function(fce,
                     expt = "sce",
                     assay = "logcounts",
                     genes = NULL,
                     n_pcs = 20,
                     scale = TRUE) {

  ## check inputs
  if (!expt %in% names(assays(fce))) {
    stop("expt not found in fce object")
  }

  if (!assay %in% names(assays(fce[[expt]]))) {
    stop("assay not found in fce object")
  }

  if (is.null(genes)) {
    genes <- rownames(fce[[expt]])
  } else {
    genes <- genes[genes %in% rownames(fce[[expt]])]
  }

  if (length(genes) == 0) {
    stop("input genes not found in fce object")
  }

  in_data <- logcounts(fce[[expt]])[genes, ]

  ## remove rows without counts
  in_data <- in_data[Matrix::rowSums(in_data) > 0, ]

  if (scale) {
    message("scaling data")
    dr_mat <- scale(t(as.matrix(in_data)), center = TRUE, scale = TRUE)
  } else {
    dr_mat <- t(in_data)
  }

  message("calculating pcs")
  n_pcs <- min(c(n_pcs, dim(dr_mat) - 1))
  pcs <- irlba::prcomp_irlba(dr_mat,
    n = n_pcs,
    center = FALSE,
    scale. = FALSE
  )

  reducedDims(fce[[expt]]) <- SimpleList(PCA = pcs$x)

  fce
}


#' Generate 2D cell embeddings using UMAP
#'
#' See <https://umap-learn.readthedocs.io> for a detailed description of
#' parameters.
#'
#' @param fce fce object
#' @param expt Data to use for UMAP, one of either sce (rna data, the default)
#'   or fsce (functional data)
#' @param method dimenality reduction method to use for UMAP, defaults to
#'   PCA
#' @param n_dims number of dimensions to pass to UMAP, defaults to all present
#'   in dr matrix
#' @param n_neighbors number of nearest neighbors to use for learning the
#'   manifold. Low values will preserve local structure, at the expense missing
#'   higher order organization. Higher values will capture more global structure
#'   but miss fine grained detail. Defaults to 30.
#' @param min_dist Numeric between 0 and 0.99. min_dist controls how tightly
#'   points can be packed together in 2D space. Lower values will generate more
#'   clumpy projections, but more accurately preserve local structure.
#' @param metric distance metric for UMAP, defaults to pearson.
#' @param seed seed to generate reproducible UMAP projection. Defaults to no
#'   seed.
#' @param ... additional arguments for [`umap::umap()`]
#'
#' @return fce object with UMAP values added to reducedDims
#' @export
calc_umap <- function(fce,
                      expt = "sce",
                      method = "PCA",
                      n_dims = NULL,
                      n_neighbors = 30,
                      min_dist = 0.3,
                      metric = "euclidean",
                      seed = NA,
                      ...) {

  ## check inputs
  if (!expt %in% names(assays(fce))) {
    stop("expt not found in fce object", call. = FALSE)
  }

  if (!method %in% names(reducedDims(fce[[expt]]))) {
    stop(paste0(c("method `", method, "` not found in fce object")), call. = FALSE)
  }

  dr_mat <- reducedDim(fce[[expt]], method)

  if (!is.null(n_dims)) {
    if (n_dims > ncol(dr_mat)) {
      stop("n_dims larger than dimensality reduction matrix")
    }
    dr_mat <- dr_mat[, 1:n_dims]
  }

  umap_res <- umap::umap(
    dr_mat,
    method = "naive",
    metric = metric,
    random_state = seed,
    min_dist = min_dist,
    n_neighbors = n_neighbors,
    n_components = 2,
    ...
  )

  reducedDims(fce[[expt]])$UMAP <- umap_res$layout

  fce
}


#' Generate 2D cell embeddings using tSNE
#'
#' See [`Rtsne::Rtsne()`] for a detailed description of parameters.
#'
#' @param fce fce object
#' @param expt Data to use for tSNE, sce (rna data, the default)
#'   or fsce (functional data)
#' @param method dimensionality reduction method for tSNE
#' @param n_dims number of dimensions for tSNE
#' @param perplexity tSNE perplexity value.
#' @param theta  tSNE theta value.
#' @param seed seed for generate reproducible tSNE projection.
#' @param ...  additional arguments for [`Rtsne::Rtsne()`]
#'
#' @return fce object with tSNE values added to reducedDims
#'
#' @export
calc_tsne <- function(fce,
                      expt = "sce",
                      method = "PCA",
                      n_dims = NULL,
                      perplexity = 30,
                      theta = 0.5,
                      seed = NA,
                      ...) {

  ## check inputs
  if (!expt %in% names(assays(fce))) {
    stop("expt not found in fce object", call. = FALSE)
  }

  if (!method %in% names(reducedDims(fce[[expt]]))) {
    stop("method not found in fce object", call. = FALSE)
  }

  dr_mat <- reducedDim(fce[[expt]], method)

  if (!is.null(n_dims)) {
    if (n_dims > ncol(dr_mat)) {
      stop("n_dims larger than dimensality reduction matrix", call. = FALSE)
    }
    dr_mat <- dr_mat[, 1:n_dims]
  }

  tsne_res <- Rtsne::Rtsne(
    dr_mat,
    perplexity = perplexity,
    theta = theta,
    check_duplicates = FALSE,
    dims = 2,
    pca = FALSE,
    verbose = FALSE,
    pca_center = FALSE,
    ...
  )

  rownames(tsne_res$Y) <- rownames(dr_mat)

  reducedDims(fce[[expt]])$TSNE <- tsne_res$Y

  fce
}
