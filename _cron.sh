#!/bin/bash

## cron job to build book from scratch routinely; save logs to ~/cronjobs/logs
## script:
## 59 23 * * * sbatch -p largenode -n 1 -c 8 --mem=128000 --tmp=20000 --wrap="bash /home/ramezqui/cronjobs/_OSCA-cron.sh 2>&1 | tee -a /home/ramezqui/cronjobs/logs/_OSCA-cron.log"

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

## Make everything; trigger knit/build again if "empty reply from server" error is encountered
## make all
make no-install

FLAG=1
while [ $FLAG -eq 1 ]; do
    ## Check based on log if "Empty reply" failure mode was invoked
    EMPTY_FAIL=$(tail -50 logs/*.out | grep "reason: Empty reply from server")
    if [ ! -z "$EMPTY_FAIL" ]; then
	echo "Build failed with empty reply from server bug, triggering a downstream job.."
	make downstream
    else
	echo "Build either succeeded or failed by some other means..wrapping up.."
	FLAG=0
    fi
done
