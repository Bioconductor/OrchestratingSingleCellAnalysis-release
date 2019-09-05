#!/bin/bash

## Write the DESCRIPTION file and install/update libraries used throughout the book

base=OSCABase

LIBLOC=/home/ramezqui/R/x86_64-pc-linux-gnu-library/3.6 # for FHCRC cluster


###################################################
## Install/update all libraries

## Dependencies
PKGS=$(grep --text -h -r "^library(" ${base} | awk '{FS=" "}{print $1}' | sort | uniq | sed 's/library(/\"/g' | sed 's/)/\", /g' | tr -d '\n\r')
PKGS=$(echo "$PKGS" | rev | cut -c 2- | rev) # remove trailing comma

## Supplemental pkgs invoked by namespace
SUPP=$(grep -o -h -r "\b\w*::\b" ${base} | sed 's/::/", "/g' | sort | uniq | tr -d '\n\r')
SUPP=$(echo \""$SUPP") # add " at beginning
SUPP=$(echo "$SUPP" | rev | cut -c 4- | rev) # remove trailing ", "

CMD=$(echo "BiocManager::install(c(${PKGS}, ${SUPP}), lib = '$LIBLOC', ask = FALSE, update = TRUE)") ## add pkg to end line properly


## Prereq packages
R --no-save --slave -e "install.packages(c('devtools', 'BiocManager', 'knitr', 'bookdown'), lib = '$LIBLOC')"

## Install dependencies
R --no-save --slave -e "${CMD}" 

## Supplementary packages (manually added)
R --no-save --slave -e "BiocManager::install(c('GO.db', 'PCAtools'), lib = '$LIBLOC')"

## Remote packages (manually added)
R --no-save --slave -e "devtools::install_github('stephenturner/msigdf', lib = '$LIBLOC')"
R --no-save --slave -e "devtools::install_github('LTLA/SingleR', lib = '$LIBLOC')"

## Check that Bioc pkgs are valid, else fix it!
R --no-save --slave -e "valid <- BiocManager::valid('$LIBLOC'); if (identical(valid, TRUE)) { quit('no') } else { BiocManager::install(rownames(valid$out_of_date), lib = '$LIBLOC') }"

## Get namespaced packages


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

## Where the magic happens to grab all the uses of library
grep --text -h -r "^library(" ${base} | awk '{FS=" "}{print $1}' | sort | uniq | sed 's/library(/    /g' | sed 's/)/,/g' >> DESCRIPTION

## Add some extra packages that aren't mentioned explicitly throughout
echo "    BiocManager" >> DESCRIPTION
echo "    devtools" >> DESCRIPTION
echo "    bookdown" >> DESCRIPTION
