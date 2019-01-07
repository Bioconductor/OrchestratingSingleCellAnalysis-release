This package contains the book contents for the companion workflows.

# Directories

* `book` - should not be manually modified; this is the output of compiling the `book-raw` folder
* `book-raw` - vignette contents are here
* `data` - RData objects used for loading into vignettes; holds intermediate, computationally expensive steps to facilitate speedy Rmd construction
* `data-raw` - any scripts used to create raw data for vignettes


# Compiling the Book

The book can be compiled by changing to the `book-raw` directory and running `make all` in bash. The book can then be viewed in a browser or as a PDF.
