#!/bin/bash

## Remove intermediate build files
rm -R P*_W*.*
rm -Rf docs
rm index.*
rm -R _bookdown_files
rm -R raw_data
rm -R workflow workflows
rm render*.rds
rm OSCA.rds
rm -Rf cache
rm -R figure

## Recreate docs folder; readd CNAME
mkdir -p docs
echo "osca.bioconductor.org" > docs/CNAME
