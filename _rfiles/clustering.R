## Clustering workflow R
library(TENxPBMCData)
library(scater)
library(scran)
library(SC3)
library(clusterExperiment)

## Load all results in
## sce <- readRDS('_rfiles/_data/clustering_sce.rds')

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

## remove uninteresting/unknown genes
sig_genes <- sig_genes[!grepl('RP[0-9]|^MT|[0-9][0-9][0-9][0-9]', sig_genes)]


## Dimension reduction ---------------------------------
sce <- runPCA(sce, ncomponents = 20, method = "irlba", feature_set = sig_genes)
sce <- runTSNE(sce, perplexity = 15, feature_set = sig_genes)

plotReducedDim(sce, "PCA", colour_by = "log10_total_counts")
plotReducedDim(sce, "TSNE", colour_by = "log10_total_counts")


## Performing clustering: SC3 -------------------------------
rowData(sce)$feature_symbol <- rownames(sce)

sce <- sc3(sce[sig_genes, ], ks = 2:4, k_estimator = TRUE)

sc3_cols <- as.data.frame(colData(sce_sc3))[, c("sc3_2_clusters", "sc3_3_clusters", "sc3_4_clusters")]

## Basic code:
g2 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_2_clusters")
g3 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_3_clusters")
g4 <- plotReducedDim(sce_sc3, use_dimred = "TSNE", colour_by = "sc3_4_clusters")
patchwork::wrap_plots(g2, g3, g4, widths = 1, heights = 1, ncol = 1)


## Performing clustering: clusterExperiment -------------------------------

## This takes a while..>15 mins on a laptop for ~2500 cells
rsec <- RSEC(sce[sig_genes, ],
            reduceMethod = "PCA", nReducedDims = 20,
            alphas = c(0.1, 0.3, 0.5),
            consensusMinSize = 50, k0s = 3)

## Extract cluster matrix
clust_mat <- as.data.frame(clusterMatrix(rsec))
rsec_clusters <- as.character(clust_mat$mergeClusters)
    
## Append to colData
colData(sce)$rsec_clusters <- rsec_clusters

## Basic code:
plotReducedDim(sce, use_dimred = "TSNE", colour_by = "rsec_clusters")


## Save results ------------------------------------------------------------
saveRDS(sce, file = "_rfiles/_data/clustering_sce.rds", compress = 'xz')



## Figures for review iSEE figure -------------------------------------------------------------
## base <- '/Users/ramezqui/Dropbox (Gottardo Lab)/GoTeam/Members/Rob/gottardo_bioc-review/'

## ## reduced dim - with clusters
## png(paste0(base, 'example_tsne.png'),
##     height = 1600, width = 3200, res = 600)
## plotTSNE(sce, colour_by = "sc3_3_clusters")
## dev.off()

## ## Feature data - base
## png(paste0(base, 'example_violins.png'),
##     height = 1200, width = 2400, res = 600)
## plotExpression(sce, c('CD79A', 'LYZ', 'CD3E'), colour_by = "total_counts")
## dev.off()

## ## Feature data - with clusters
## png(paste0(base, 'example_violins_facet-clusters.png'),
##     height = 1200, width = 2400, res = 600)
## plotExpression(sce, c('CD79A', 'LYZ', 'CD3E'), x = "sc3_3_clusters",
##                colour_by = "sc3_3_clusters", ncol = 3)
## dev.off()

## ## coldata plot
## png(paste0(base, 'example_coldata.png'),
##     height = 1200, width = 1600, res = 600)
## plotColData(sce, y = "total_features_by_counts", x = "Individual")
## dev.off()

## png(paste0(base, 'example_coldata_facet-clusters.png'),
##     height = 1200, width = 2400, res = 600)
## plotColData(sce, y = "total_counts", x = "sc3_3_clusters",
##             colour_by = "sc3_3_clusters")
## dev.off()
