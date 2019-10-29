#!/bin/bash

## cron job to install prerequisite packages for book on clean (login) node
## script:
## 0 22 * * * bash /home/ramezqui/cronjobs/_OSCA-cron-install.sh 2>&1 | tee -a /home/ramezqui/cronjobs/logs/_OSCA-cron.log

## FHCRC specific modules ------------------------------------------------------
source /app/Lmod/lmod/lmod/init/bash
source /home/ramezqui/.bashrc  # contains custom R + module system + pandoc

## Build book -------------------------------------------------------------------
## Set the working TEMP directory
TMPDIR=$(mktemp -d)
cd $TMPDIR

echo "Build time is $(date) ..."
echo "Writing to ${TMPDIR} ..."
echo "Using the following R: $(echo $(which R))"

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

## Make everything; trigger knit/build again if "empty reply from server" error is encountered
make install
