#!/bin/bash

## Write the DESCRIPTION file and install/update libraries used throughout the book

BASE=OSCABase
BIOCVERSION=3.10

## Library location; assume R_LIBS_USER is first in .libPaths()
LIBLOC=$(R --no-save --slave -e "cat(.libPaths()[1])") 

## Remove any lock files
rm -Rf $LIBLOC/*LOCK*

###################################################
## Install/update all libraries

## Core libraries
PKGS=$(grep -h -r "^library(" ${BASE} | awk '{FS=" "}{print $1}' | sort | uniq | sed 's/library(/\"/g' | sed 's/)/\", /g' | tr -d '\n\r')
PKGS=$(echo "$PKGS" | rev | cut -c 3- | rev) # remove trailing comma

## Supplemental pkgs invoked by namespace
SUPP=$(grep -o -h -r "\b\w*::\b" ${BASE} | sed 's/::/", "/g' | sort | uniq | tr -d '\n\r')
SUPP=$(echo \""$SUPP") # add " at beginning
SUPP=$(echo "$SUPP" | rev | cut -c 4- | rev) # remove trailing ", "

CMD=$(echo "BiocManager::install(unique((c(${PKGS}, ${SUPP}))), lib = '$LIBLOC', ask = FALSE, update = TRUE, version = '$BIOCVERSION')") ## add pkg to end line properly


## Install prerequisite packages
R --no-save --slave -e "install.packages(c('devtools', 'remotes', 'BiocManager', 'knitr', 'bookdown'), lib = '$LIBLOC', ask = FALSE, update = TRUE)"

## Install core libraries
R --no-save --slave -e "BiocManager::install(version = '$BIOCVERSION')"
R --no-save --slave -e "${CMD}"

## Install remote (github) packages (manually added)
R --no-save --slave -e "remotes::install_github('stephenturner/msigdf', lib = '$LIBLOC', ask = FALSE, update = TRUE)"

## Check that Bioc pkgs are valid, else fix it!
R --no-save --slave -e "valid <- BiocManager::valid('$LIBLOC'); if (identical(valid, TRUE)) { quit('no') } else { BiocManager::install(rownames(valid$out_of_date), lib = '$LIBLOC', version = '$BIOCVERSION') }"

## Install some Bioc packages manually
R --no-save --slave -e "BiocManager::install('GO.db', lib = '$LIBLOC', version = '$BIOCVERSION')"


###################################################
## Install OSCAUtils (package inside OSCABase)

R --no-save --slave -e "devtools::install('OSCABase/package')"


###################################################
## Bonus: Write the DESCRIPTION file automagically 

echo "Package: OrchestratingSingleCellAnalysis" > DESCRIPTION
echo "Title: Orchestrating Single Cell Analysis with Bioconductor" >> DESCRIPTION
echo "Version: 0.0.1.9999" >> DESCRIPTION
echo "Authors@R: c(person('Robert', 'Amezquita', role = c('aut', 'cre')), person('Aaron', 'Lun', role = c('aut')), person('Stephanie', 'Hicks', role = 'aut'), person('Raphael', 'Gottardo', role = 'aut'))" >> DESCRIPTION
echo "Description: Online book for orchestrating single cell analysis with Bioconductor. Methods and resources with plenty of examples." >> DESCRIPTION
echo "License: GPL-3" >> DESCRIPTION
echo "Encoding: UTF-8" >> DESCRIPTION
echo "LazyData: true" >> DESCRIPTION
echo "Imports:" >> DESCRIPTION

## Add all the libraries discovered in the first section
ALL=$(echo "$PKGS $SUPP" | sed 's/", /\n\r/g' | sed 's/"//g' | sed 's/,//' | sort | uniq)
echo "$ALL" >> DESCRIPTION

## Add some extra packages that aren't mentioned explicitly throughout
echo "    devtools" >> DESCRIPTION
echo "    bookdown" >> DESCRIPTION
