#!/bin/bash

base=OSCABase

## NOTE: To build clean, run `make clean` (or run _cron.sh)

## Update the local repo `OrchestratingSingleCellAnalysis`
git pull

# Updating the submodule remotes of `OSCABase`
## git submodule add git@github.com:Bioconductor/OSCABase.git
git submodule update --init
git submodule update --remote

# Clone the logs storage repo
git clone git@github.com:robertamezquita/OSCAlogs.git

###################################################
# Intro files:
cp ${base}/intro/index.Rmd index.Rmd

allfiles=(
introduction.Rmd
learning-r-and-bioconductor.Rmd
beyond-r-basics.Rmd
data-infrastructure.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P1_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/intro/${allfiles[$i]} $newfile
done

###################################################
# Analysis files:

allfiles=(
overview.Rmd
quality-control.Rmd
normalization.Rmd
feature-selection.Rmd
reduced-dimensions.Rmd
clustering.Rmd
marker-detection.Rmd
cell-annotation.Rmd
data-integration.Rmd
sample-comparisons.Rmd
doublet-detection.Rmd
cell-cycle.Rmd
trajectory.Rmd
protein-abundance.Rmd
repertoire-seq.Rmd
interactive.Rmd
big-data.Rmd
interoperability.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P2_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/${allfiles[$i]} $newfile
done

cp ${base}/ref.bib .

###################################################
# Workflow files.

# NOTE: these are copied *in addition* to the copying of the workflows above.
# This is to enable them to be chapters in their own right.

allfiles=(
lun-416b.Rmd
zeisel-brain.Rmd
tenx-unfiltered-pbmc4k.Rmd
tenx-filtered-pbmc3k-4k-8k.Rmd
tenx-repertoire-pbmc8k.Rmd
grun-pancreas.Rmd
muraro-pancreas.Rmd
lawlor-pancreas.Rmd
segerstolpe-pancreas.Rmd
merged-pancreas.Rmd
pijuan-embryo.Rmd
bach-mammary.Rmd
hca-bone-marrow.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P3_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/workflows/${allfiles[$i]} $newfile
done

###################################################
# About files:

allfiles=(
about-the-contributors.Rmd
bibliography.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P4_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/about/${allfiles[$i]} $newfile
done
