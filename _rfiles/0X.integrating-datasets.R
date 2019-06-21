#----echo=FALSE, message=FALSE-------------------------------------------
precalculated essential results for plots at end
sce <- readRDS("_rfiles/_data/integration_sce_min.rds")


## ----prereqs, eval=FALSE-------------------------------------------------
## required
BiocManager::install(c('scater', 'scran', 'limma', 'TENxPBMCData'))

## suggested
BiocManager::install(c('BiocParallel', 'BiocNeighbors'))


## ----preamble, message=FALSE---------------------------------------------
library(scater)
library(scran)
library(limma)
library(TENxPBMCData)
library(BiocParallel)
library(BiocNeighbors)


## ----eval=FALSE----------------------------------------------------------
pbmc3k <- TENxPBMCData('pbmc3k')
pbmc4k <- TENxPBMCData('pbmc4k')


## ----eval=FALSE----------------------------------------------------------
keep_genes <- intersect(rownames(pbmc3k), rownames(pbmc4k))
pbmc3k <- pbmc3k[match(keep_genes, rownames(pbmc3k)), ]
pbmc4k <- pbmc4k[na.omit(match(keep_genes, rownames(pbmc4k))), ]


## ----eval=FALSE----------------------------------------------------------
## For pbmc3k
pbmc3k <- calculateQCMetrics(pbmc3k)
low_lib_pbmc3k <- isOutlier(pbmc3k$log10_total_counts, type="lower", nmad=3)
low_genes_pbmc3k <- isOutlier(pbmc3k$log10_total_features_by_counts, type="lower", nmad=3)

## For pbmc4k
pbmc4k <- calculateQCMetrics(pbmc4k)
low_lib_pbmc4k <- isOutlier(pbmc4k$log10_total_counts, type="lower", nmad=3)
low_genes_pbmc4k <- isOutlier(pbmc4k$log10_total_features_by_counts, type="lower", nmad=3)


## ----eval=FALSE----------------------------------------------------------
pbmc3k <- pbmc3k[, !(low_lib_pbmc3k | low_genes_pbmc3k)]
pbmc4k <- pbmc4k[, !(low_lib_pbmc4k | low_genes_pbmc4k)]


## ----eval=FALSE----------------------------------------------------------
## compute the sizeFactors
pbmc3k <- computeSumFactors(pbmc3k)
pbmc4k <- computeSumFactors(pbmc4k)

## Normalize (using already calculated size factors)
pbmc3k <- normalize(pbmc3k)
pbmc4k <- normalize(pbmc4k)


## ----eval=FALSE----------------------------------------------------------
fit_pbmc3k <- trendVar(pbmc3k, use.spikes=FALSE)
dec_pbmc3k <- decomposeVar(pbmc3k, fit_pbmc3k)
dec_pbmc3k$Symbol_TENx <- rowData(pbmc3k)$Symbol_TENx
dec_pbmc3k <- dec_pbmc3k[order(dec_pbmc3k$bio, decreasing = TRUE), ]

fit_pbmc4k <- trendVar(pbmc4k, use.spikes=FALSE)
dec_pbmc4k <- decomposeVar(pbmc4k, fit_pbmc4k)
dec_pbmc4k$Symbol_TENx <- rowData(pbmc4k)$Symbol_TENx
dec_pbmc4k <- dec_pbmc4k[order(dec_pbmc4k$bio, decreasing = TRUE), ]


## ----eval=FALSE----------------------------------------------------------
universe <- intersect(rownames(dec_pbmc3k), rownames(dec_pbmc4k))
mean.bio <- (dec_pbmc3k[universe,"bio"] + dec_pbmc4k[universe,"bio"])/2
hvg_genes <- universe[mean.bio > 0]


## ----eval=FALSE----------------------------------------------------------
## total raw counts
counts_pbmc <- cbind(counts(pbmc3k), counts(pbmc4k))

## total normalized counts (with multibatch normalization)
logcounts_pbmc <- cbind(logcounts(pbmc3k), logcounts(pbmc4k))

sce <- SingleCellExperiment(
    assays = list(counts = counts_pbmc, logcounts = logcounts_pbmc),
    rowData = rowData(pbmc3k), # same as rowData(pbmc4k)
    colData = rbind(colData(pbmc3k), colData(pbmc4k))
)


## ----eval=FALSE----------------------------------------------------------
metadata(sce)$hvg_genes <- hvg_genes


## ----eval=FALSE----------------------------------------------------------
## Manual assignment of PCA to sce object
## px <- prcomp(t(logcounts(sce)[hvg_genes, ]))
## reducedDim(sce, "PCA_naive") <- px$x[, 1:20]

## Method for automating PCA calculation/saving into sce with additional
## parameters for speeding up calculation via Irlba/parallelization
sce <- runPCA(sce,
              ncomponents = 20,
              feature_set = hvg_genes,
              method = "irlba",
              BPPARAM = MulticoreParam(8))

names(reducedDims(sce)) <- "PCA_naive" # rename for clarity; prevent overwriting


## ------------------------------------------------------------------------
plotReducedDim(sce, use_dimred = "PCA_naive",
               colour_by = "Sample") + 
    ggtitle("PCA Without batch correction")


## ----eval=FALSE----------------------------------------------------------
limma_corrected <- limma::removeBatchEffect(logcounts(sce), batch = sce$Sample)
assay(sce, "logcounts_limma") <- limma_corrected ## add new assay

## Automated way of running PCA
sce <- runPCA(sce,
              ncomponents = 20,
              feature_set = hvg_genes,
              exprs_values = "logcounts_limma",
              method = "irlba",
              BPPARAM = MulticoreParam(8))

names(reducedDims(sce))[2] <- "PCA_limma"


## ------------------------------------------------------------------------
plotReducedDim(sce, use_dimred = "PCA_limma",
               colour_by = "Sample") + 
    ggtitle("PCA With limma removeBatchEffect() correction")


## ----eval=FALSE----------------------------------------------------------
rescaled <- multiBatchNorm(pbmc3k, pbmc4k)
pbmc3k_rescaled <- rescaled[[1]]
pbmc4k_rescaled <- rescaled[[2]]


## ----eval=FALSE----------------------------------------------------------
## Basic method - not run
## mnn_out <- fastMNN(pbmc3k_rescaled,
##                    pbmc4k_rescaled,
##                    subset.row = metadata(sce)$hvg_genes,
##                    k = 20, d = 50, approximate = TRUE)


## ----eval=FALSE----------------------------------------------------------
## Adding parallelization and Annoy method for approximate nearest neighbors
## this makes fastMNN faster on large data
mnn_out <- fastMNN(pbmc3k_rescaled, #[hvg_genes, ],
                   pbmc4k_rescaled, #[hvg_genes, ],
                   subset.row = metadata(sce)$hvg_genes,
                   k = 20, d = 50, approximate = TRUE,
                   BNPARAM = BiocNeighbors::AnnoyParam(),
                   BPPARAM = BiocParallel::MulticoreParam(8))

reducedDim(sce, "MNN") <- mnn_out$correct


## ------------------------------------------------------------------------
plotReducedDim(sce, use_dimred = "MNN",
                    colour_by = "Sample") + 
    ggtitle("MNN Ouput Reduced Dimensions")


## ------------------------------------------------------------------------
## sessionInfo()


## ---- eval=FALSE, echo=FALSE---------------------------------------------
## Trim sce object prior to saving to save space
sce_min <- SingleCellExperiment(
    assays = list(),
    colData = colData(sce)[, c('Sample', 'Barcode')],
    reducedDims = list(PCA_naive = reducedDim(sce, 'PCA_naive'),
                       PCA_limma = reducedDim(sce, 'PCA_limma'),
                       MNN = reducedDim(sce, 'MNN'))
)

## Save sce file
## saveRDS(sce_min, "_rfiles/_data/integration_sce.rds")
saveRDS(sce_min, "integration_sce_min.rds")

## saveRDS(sce, "_rfiles/_data/integration_sce.rds")
## saveRDS(sce, "integration_sce.rds", compress = "xz")

