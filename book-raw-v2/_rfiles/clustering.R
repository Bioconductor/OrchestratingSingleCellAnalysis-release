## Clustering workflow R file

library(TENxPBMCData)
library(scater)
library(scran)

## Load dataset
sce <- TENxPBMCData(dataset = "pbmc3k")
rownames(sce) <- rowData(sce)$Symbol_TENx # for readability
colnames(sce) <- colData(sce)$Barcode 
counts(sce) <- as.matrix(counts(sce)) # convert to in-memory

## Producing a clean expression matrix -----------------
## Calculate QC metrics
sce <- calculateQCMetrics(sce)

## Filter by low library/features detected
low_lib_sce <- isOutlier(sce$log10_total_counts,
                        type = "lower", nmad = 3)
low_ftr_sce <- isOutlier(sce$log10_total_features_by_counts,
                        type = "lower", nmad = 3)

sce <- sce[, !(low_lib_sce | low_ftr_sce)]

## Perform clustering for better size factor calculations
qclust <- quickCluster(sce, min.size = 100,
                      method = "igraph", use.ranks = FALSE)
## table(qclust)

## size factor normalization with quick clusters
sce <- computeSumFactors(sce, clusters = qclust)

## Normalize using calculated size factors
sce <- normalize(sce)


## Calculating highly variable genes -------------------
fit <- trendVar(sce, parametric=TRUE, use.spikes = FALSE)
dec <- decomposeVar(sce, fit)
sig_genes <- rownames(dec[dec$FDR < 0.00001, ])


## Dimension reduction ---------------------------------
sce <- runTSNE(sce, perplexity = 15, feature_set = sig_genes)

plotReducedDim(sce, "TSNE", colour_by = "log10_total_counts")


## Performing clustering -------------------------------
library(SC3)

rowData(sce)$feature_symbol <- rownames(sce)

sce_sc3 <- sc3(sce[sig_genes, ], ks = 2:4, k_estimator = TRUE)











