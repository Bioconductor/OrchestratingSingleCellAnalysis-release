#!/bin/bash

# Follows from updating the book and pulling it (_update.sh)

###################################################
# Knit appendix workflow files
## NOTE: rmarkdown::render() does not seem to work
## well with BiocFileCache() files..switching to knitr

set -ev

for I in $(ls | grep "P3_.*.Rmd$"); do
    echo "Rendering $I .."
    R --no-save --quiet -e "rmarkdown::render('workflows/${I}')"
done
