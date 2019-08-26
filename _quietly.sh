#!/bin/bash

## Build the book interactively and NOW! (with logging added and cleanup afterwards)
mkdir -p logs
make all > logs/_OSCA-cron.log 2> logs/_OSCA-cron.out
git clone git@github.com:robertamezquita/OSCAlogs.git
cp logs/* OSCAlogs
cd OSCAlogs
git add *
git commit -m 'logs from $(date)'
git push
cd ..

