all: update build

update:
	@echo "Updating repo..."
	./_update.sh

build:
	@echo "Building book..."
	./_build.sh

clean:
	@echo "Cleaning up..."
	./_clean.sh
