#!/bin/bash

## cron job to build book from scratch routinely; save logs to ~/cronjobs/logs
## script:
## 59 23 * * * bash /home/{USER}/cronjobs/_OSCA-cron.sh >/home/{USER}/cronjobs/logs/_OSCA-cron.log 2>/home/{USER}/cronjobs/logs/_OSCA-cron.out


## FHCRC specific modules ------------------------------------------------------
source /app/Lmod/lmod/lmod/init/bash
source /home/ramezqui/.bashrc  # contains custom R + module system + pandoc

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

## Clone and change permission on executables
git clone git@github.com:Bioconductor/${REPO}.git
cd $REPO
chmod 755 *.sh

## Make everything
## If successful, pushes new book version automatically; if fail push the log out
make all || (make log && exit 1)
make log
