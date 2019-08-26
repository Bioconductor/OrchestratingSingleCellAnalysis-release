#!/bin/bash

## cron job to build book from scratch routinely; save logs to ~/cronjobs/logs
## script:
## 59 23 * * * bash /home/{USER}/cronjobs/_OSCA-cron.sh >/home/{USER}/cronjobs/logs/_OSCA-cron.log 2>/home/{USER}/cronjobs/logs/_OSCA-cron.out


## FHCRC specific modules ------------------------------------------------------
source /app/Lmod/lmod/lmod/init/bash
module use /app/easybuild/modules/all
## source ~/.github_pat   # github access token only needed for https remotes
ml R/3.6.1-foss-2016b-fh1
ml pandoc


## Cron job script -------------------------------------------------------------
## Set the working TEMP directory
TMPDIR=$(mktemp -d)
cd $TMPDIR

echo "Build time is $(date) ..."
echo "Writing to ${TMPDIR} ..."

REPO=OrchestratingSingleCellAnalysis

# Absolutely critical that this is a fresh clone.
if [ -e ${REPO} ]
then
    rm -rf ${REPO}
fi

## git clone https://github.com/Bioconductor/${REPO}.git # for token method
git clone git@github.com:Bioconductor/${REPO}.git
cd ${REPO}
git pull

## Add OSCABase submodule
git submodule add https://github.com/Bioconductor/OSCABase
git submodule update --init

# Copy over Rmds from OSCABase; run workflows; update DESCRIPTION
make all  # update docs, (re)install/update pkgs, knit workflows, build book

# There had better be nothing in 'docs' that is not meant to be added!
git add docs/
git commit -m "Rebuilt book on $(date)."

# Make a personal access tokenized push
## TOKEN=${GITHUB_PAT}  ## required for remote to use https
## git push https://${TOKEN}:x-oauth-basic@github.com/Bioconductor/${REPO} master
git push # only works if pushing via ssh


## Logging ---------------------------------------------------------------------
## Push some logs out
git clone git@github.com:robertamezquita/OSCAlogs.git
cd OSCAlogs
cp ~/cronjobs/logs/* .
git add -A
git commit -m "Logs compiled on $(date)."
git push


