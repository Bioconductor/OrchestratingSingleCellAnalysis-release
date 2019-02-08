## Clustering workflow R file

library(TENxPBMCData)
library(scater)
library(scran)
library(SC3)
library(clusterExperiment)

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
sce <- runPCA(sce, ncomponents = 20, method = "irlba", feature_set = sig_genes)
sce <- runTSNE(sce, perplexity = 15, feature_set = sig_genes)

plotReducedDim(sce, "PCA", colour_by = "log10_total_counts")
plotReducedDim(sce, "TSNE", colour_by = "log10_total_counts")


## Performing clustering: SC3 -------------------------------
rowData(sce)$feature_symbol <- rownames(sce)

sce_sc3 <- sc3(sce[sig_genes, ], ks = 2:4, k_estimator = TRUE)

## Basic code:
g2 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_2_clusters")
g3 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_3_clusters")
g4 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_4_clusters")
patchwork::wrap_plots(g2, g3, g4, widths = 1, heights = 1, ncol = 1)

## ## Alternate code: Plot the various clusters programmatically
## cols <- paste0("sc3_", 2:4, "_clusters")
## g <- lapply(cols, function(sce, col) {
##     plotReducedDim(sce, use_dimred = "TSNE", colour_by = col) +
##         theme(legend.position = "none")
## }, sce = sce_sc3)
## patchwork::wrap_plots(g, widths = 1, heights = 1)

cols <- paste0("sc3_", 2:4, "_clusters") # "sc3_*_clusters"

sc3_plot_consensus(sce_sc3, k = 3, show_pdata = cols)

## Performing clustering: clusterExperiment -------------------------------

## This takes a while..>15 mins on a laptop for ~2500 cells
rsec <- RSEC(sce[sig_genes, ], reduceMethod = "PCA", nReducedDims = 20,
            alphas = 0.1,
            consensusMinSize = 100, k0s = 2:4)

plotCoClustering(rsec, whichClusters = c("mergeClusters", "makeConsensus"))



save(sce, sce_sc3, rsec, file = "_rfiles/_data/clustering.RData", compress = 'xz')



