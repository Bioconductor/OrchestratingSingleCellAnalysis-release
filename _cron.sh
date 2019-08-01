#!/bin/bash

## cron job to build book from scratch routinely

## FHCRC specific modules -----------------------------
source /app/Lmod/lmod/lmod/init/bash
module use /app/easybuild/modules/all
source ~/.github_pat   # github access token env var
ml R/3.6.1-foss-2016b-fh1
ml pandoc
mkdir -p ~/cronjobs/builds ~/cronjobs/logs
cd ~/cronjobs/builds



## Cron job script ------------------------------------
echo "Build time is $(date) ..."

TMPDIR=$(mktemp -d)
cd $TMPDIR

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
TOKEN=${GITHUB_PAT}
git push https://${TOKEN}:x-oauth-basic@github.com/Bioconductor/${REPO} master
