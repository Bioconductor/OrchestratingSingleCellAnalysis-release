#!/bin/bash

# Follows from updating the book and pulling it (_update.sh)

###################################################
# Knit appendix workflow files
## NOTE: rmarkdown::render() does not seem to work
## well with BiocFileCache() files..switching to knitr

set -ev

WORKFLOWS=(
    bach-mammary
    grun-pancreas
    lawlor-pancreas
    lun-416b
    muraro-pancreas
    pijuan-embryo
    segerstolpe-pancreas
    tenx-filtered-pbmc3k
    tenx-filtered-pbmc4k
    tenx-unfiltered-pbmc4k
    zeisel-brain
)

for I in ${WORKFLOWS[*]}; do
    echo "Rendering $I .."
    R --no-save --quiet -e "rmarkdown::render('workflows/${I}.Rmd')"
done
