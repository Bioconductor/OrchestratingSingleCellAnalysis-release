This is the companion online book for the manuscript "Orchestrating Single-Cell Analysis with Bioconductor" by the Bioconductor community (2019).


## Build Instructions

To build the book, run `make all`, which will update the book files, install all the discovered packages used throughout, and then render the workflows and the book itself. If the build is successful, it will attempt to push the new version of the book to Github at this repo as well as the logs to `github.com/robertamezquita/OSCAlogs`. Logs are kept in the `logs` folder after the build.

In order to save the logs of the build - whether the build is successful or otherwise - run `make all || (make log && exit 1)`. Note that this includes (re)installing all packages used throughout the book.

To skip installing packages, use the `make no-install` recipe.

For running daily builds, `_cron.sh` provides a script that automates the build process for the Fred Hutch cluster.

### Details

The `Makefile` contains all the individual steps that can be run through. In order:

* `make clean` (runs `_clean.sh`) : removes all files associated with the actual book content
* `make update` (runs `_update.sh`) : updates the book content files, pulling the ; pulls out the various chapters and workflows to the top-level to prepare for the R `bookdown` package to build the book
* `make install` (runs `_install.sh`) : installs all required packages invoked throughout the book with `library()` or via the namespace operator `::`; also updates the `DESCRIPTION` file
* `make knit` (runs `_knit.sh`) : knits the `workflows` folder from `OSCABase`, which consists of preliminary datasets used throughout the book
* `make build` (runs `_build.sh`, which calls `_render.R`) : builds the book using R `bookdown` package
* `make push` (runs `_push.sh`) : pushes the new book version up to `Bioconductor/OrchestratingSingleCellAnalysis`
* `make log` (runs `_log.sh`) : pushes the logs generated throughout the build install/knit/build process (that are saved in `logs` folder) up to `robertamezquita/OSCAlogs`



## Requirements

Requires the latest version of R (3.6.1) and pandoc. Various R packages are required, which can be seen in `DESCRIPTION` and discovered/installed directly from the book contents via `_install.sh`.



