#!/bin/bash

base=OSCABase

# Updating the submodule remotes.
git submodule update --remote

###################################################
# Intro files:

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
quick-start.Rmd
basic-analysis.Rmd
quality-control.Rmd
normalization.Rmd
clustering.Rmd
marker-detection.Rmd
data-integration.Rmd
cell-annotation.Rmd
interactive.Rmd
trajectory.Rmd
big-data.Rmd
import-export.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P2_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/${allfiles[$i]} $newfile
done

# Copying the workflows as well.
cp -r ${base}/analysis/workflows .

cp ${base}/ref.bib .

###################################################
# About files:

allfiles=(
about-the-data.Rmd
about-the-contributors.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P3_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/about/${allfiles[$i]} $newfile
done

