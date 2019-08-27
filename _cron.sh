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


## Build book -------------------------------------------------------------------
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

## Make everything
## If successful, pushes new book version automatically
make all

## And no matter what, by running this the logs are saved to the cloud
make log
