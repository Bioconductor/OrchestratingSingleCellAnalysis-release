#!/bin/bash

## Update online book and build logs -------------------------------------------
# There had better be nothing in 'docs' that is not meant to be added!
git add docs/
git commit -m "Rebuilt book on $(date)."
git push # only works via ssh

## Transfer logs over to the OSCAlogs dir and push
cp logs/* OSCAlogs
cd OSCAlogs
git add *
git commit -m 'build date: $(date)'
git push
cd ..


## NOTE: Token option below; only works with https based repos
## Make a personal access tokenized push
## TOKEN=${GITHUB_PAT}  ## required for remote to use https
## git push https://${TOKEN}:x-oauth-basic@github.com/Bioconductor/${REPO} master
