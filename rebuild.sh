#!/bin/bash

base=OSCABase

# Updating the submodule remotes.
git submodule update --remote

# Copying over the files in the specified order.
allfiles=(
overview.Rmd
quick-start.Rmd
basic-analysis.Rmd
quality-control.Rmd
normalization.Rmd
clustering.Rmd
diff-exp.Rmd
data-integration.Rmd
cell-annotation.Rmd
interactive.Rmd
trajectory.Rmd
big-data.Rmd
import-export.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P2_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/${allfiles[$i]} $newfile
done

# Copying the workflows as well.
cp -r ${base}/workflows .
