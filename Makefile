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
	./_install.sh #  > logs/_OSCA-logs.out 2>&1

knit:
	@echo "Knitting workflows..."
	./_knit.sh # >> logs/_OSCA-logs.out 2>&1

build:
	@echo "Building book..."
	./_build.sh # >> logs/_OSCA-logs.out 2>&1


## Note that if build fails, push will not be performed: ---
push:
	@echo "Pushing up new book version..."
	./_push.sh

log:
	@echo "Pushing up logs..."
	./_log.sh
