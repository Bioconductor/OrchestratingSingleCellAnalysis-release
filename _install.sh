#!/bin/bash

## Write the DESCRIPTION file and install/update libraries used throughout the book

base=OSCABase

## Library location; assume R_LIBS_USER is first in .libPaths()
LIBLOC=$(R --no-save --slave -e "cat(.libPaths()[1])") 


###################################################
## Install/update all libraries

## Dependencies
PKGS=$(grep --text -h "^library(" ${base}/*/*.R* | awk '{FS=" "}{print $1}' | sort | uniq | sed 's/library(/\"/g' | sed 's/)/\", /g' | tr -d '\n\r')
PKGS=$(echo "$PKGS" | rev | cut -c 3- | rev) # remove trailing comma

## Supplemental pkgs invoked by namespace
SUPP=$(grep -o -h -r "\b\w*::\b" ${base}/*/*.R* | sed 's/::/", "/g' | sort | uniq | tr -d '\n\r')
SUPP=$(echo \""$SUPP") # add " at beginning
SUPP=$(echo "$SUPP" | rev | cut -c 4- | rev) # remove trailing ", "

CMD=$(echo "BiocManager::install(c(${PKGS}, ${SUPP}), lib = '$LIBLOC', ask = FALSE, update = TRUE)") ## add pkg to end line properly


## Prereq packages
R --no-save --slave -e "install.packages(c('devtools', 'remotes', 'BiocManager', 'knitr', 'bookdown'), lib = '$LIBLOC')"

## Install dependencies
R --no-save --slave -e "${CMD}" 

## Remote packages (manually added)
R --no-save --slave -e "remotes::install_github('stephenturner/msigdf', lib = '$LIBLOC', ask = FALSE, update = TRUE)"

## Check that Bioc pkgs are valid, else fix it!
R --no-save --slave -e "valid <- BiocManager::valid('$LIBLOC'); if (identical(valid, TRUE)) { quit('no') } else { BiocManager::install(rownames(valid$out_of_date), lib = '$LIBLOC') }"


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
