#!/bin/bash

## cron job to build book from scratch routinely

## FHCRC specific modules
## ml R # should load the latest R version
ml R/3.6.1-foss-2016b-fh1
ml pandoc
source ~/.github_pat


REPO=OrchestratingSingleCellAnalysis

# Absolutely critical that this is a fresh clone.
if [ -e ${REPO} ]
then
    rm -rf ${REPO}
fi
git clone https://github.com/Bioconductor/${REPO}

cd ${REPO}
git pull

## Add OSCABase submodule
git submodule add https://github.com/Bioconductor/OSCABase
git submodule update --init

# Copy over Rmds from OSCABase; run workflows; update DESCRIPTION
bash _update.sh
git add OSCABase
git commit -m "Updated OSCABase."

## (Re)build the book
bash _build.sh

# There had better be nothing in 'docs' that is not meant to be added!
git add docs/
git commit -m "Rebuilt book."

# Make a personal access token.
# TOKEN=${GITHUB_PAT}
# git push https://${TOKEN}:x-oauth-basic@github.com/Bioconductor/${REPO} master
