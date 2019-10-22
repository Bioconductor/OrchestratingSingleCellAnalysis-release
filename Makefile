all: clean update install knit build push log
no-install: clean update knit build push log
downstream: knit build push log

clean:
	@echo "Cleaning up..."
	./_clean.sh 

update:
	@echo "Updating files..."
	./_update.sh

install:
	@echo "Installing prerequisite packages..."
	./_install.sh 2>&1 | tee logs/_OSCA-logs.out 

knit:
	@echo "Knitting workflows..."
	./_knit.sh 2>&1 | tee -a logs/_OSCA-logs.out 

build:
	@echo "Building book..."
	./_build.sh 2>&1 | tee -a logs/_OSCA-logs.out 


## Note that if build fails, push will not be performed: ---
push:
	@echo "Pushing up new book version..."
	./_push.sh 2>&1 | tee -a logs/_OSCA-logs.out 

log:
	@echo "Pushing up logs..."
	./_log.sh 2>&1 | tee -a logs/_OSCA-logs.out 
