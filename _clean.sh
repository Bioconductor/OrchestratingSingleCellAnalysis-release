#!/bin/bash

## Remove intermediate build files
rm -R P*_W*.*
rm -Rf docs
rm index.*
rm -Rf _bookdown_files
rm -Rf raw_data
rm -Rf workflow workflows
rm render*.rds
rm OSCA.rds
rm -Rf cache
rm -Rf figure

rm -Rf logs
rm -Rf OSCAlogs

## Recreate docs folder; re-add CNAME
mkdir -p docs
echo "osca.bioconductor.org" > docs/CNAME

## Clean logs dir
mkdir -p logs
