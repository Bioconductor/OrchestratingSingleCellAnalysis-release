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
interactive.Rmd
big-data.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P2_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/${allfiles[$i]} $newfile
done

# Copying the workflows as well.
cp -r ${base}/analysis/workflows .

cp ${base}/ref.bib .

###################################################
# Workflow files.

# NOTE: these are copied *in addition* to the copying of the workflows above.
# This is to enable them to be chapters in their own right.

allfiles=(
grun-pancreas.Rmd
lun-416b.Rmd
segerstolpe-pancreas.Rmd
zeisel-brain.Rmd
lawlor-pancreas.Rmd
muraro-pancreas.Rmd
tenx-unfiltered-pbmc4k.Rmd
tenx-filtered-pbmc3k.Rmd
tenx-filtered-pbmc4k.Rmd
pijuan-embryo.Rmd
bach-mammary.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P3_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/workflows/${allfiles[$i]} $newfile
done

###################################################
# About files:

allfiles=(
about-the-data.Rmd
about-the-contributors.Rmd
bibliography.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P4_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/about/${allfiles[$i]} $newfile
done
