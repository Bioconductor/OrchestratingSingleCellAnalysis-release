#!/bin/sh

## adapted from: https://github.com/rstudio/bookdown/blob/master/inst/examples/Makefile
## adapted from: https://github.com/Bioconductor/BiocWorkshops2019/blob/master/_build.sh

set -ev

## Rscript --verbose _render.R "bookdown::pdf_book"
Rscript --verbose _render.R "bookdown::gitbook"
## Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
