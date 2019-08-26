#!/bin/bash

# Follows from updating the book and pulling it (_update.sh)

###################################################
# Knit appendix workflow files
## NOTE: rmarkdown::render() does not seem to work
## well with BiocFileCache() files..switching to knitr


for I in $(ls workflows/*.Rmd); do
    echo "Rendering $I .."
    R --no-save --quiet -e "knitr::knit('${I}', output = 'workflows/$(basename ${I} .Rmd).html')"
done

## Original command:
## R --no-save --quiet -e "wf <- list.files('workflows', pattern='Rmd$', full=TRUE, recursive=TRUE); wf <- wf[!grepl('template.Rmd', wf)]; for (x in wf) { rmarkdown::render(x) }"

