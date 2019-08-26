all: clean update install knit build

update:
	@echo "Updating files..."
	./_update.sh

install:
	@echo "Installing prerequisite packages..."
	./_install.sh

knit:
	@echo "Knitting workflows..."
	./_knit.sh

build:
	@echo "Building book..."
	./_build.sh

clean:
	@echo "Cleaning up..."
	./_clean.sh
