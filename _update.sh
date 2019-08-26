#!/bin/bash

base=OSCABase

## NOTE: To build clean, run `make clean` (or run _cron.sh)

# Updating the submodule remotes.
git submodule update --remote

###################################################
# Intro files:
cp ${base}/intro/index.Rmd index.Rmd

allfiles=(
introduction.Rmd
learning-r-and-bioconductor.Rmd
beyond-r-basics.Rmd
data-infrastructure.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P1_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/intro/${allfiles[$i]} $newfile
done

###################################################
# Analysis files:

allfiles=(
overview.Rmd
quick-start.Rmd
basic-analysis.Rmd
quality-control.Rmd
normalization.Rmd
feature-selection.Rmd
reduced-dimensions.Rmd
clustering.Rmd
marker-detection.Rmd
doublet-detection.Rmd
data-integration.Rmd
sample-comparisons.Rmd
interactive.Rmd
big-data.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P2_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/${allfiles[$i]} $newfile
done

# Copying the workflows as well.
cp -r ${base}/analysis/workflows .

cp ${base}/ref.bib .

###################################################
# Workflow files.

# NOTE: these are copied *in addition* to the copying of the workflows above.
# This is to enable them to be chapters in their own right.

allfiles=(
grun-pancreas.Rmd
lun-416b.Rmd
segerstolpe-pancreas.Rmd
zeisel-brain.Rmd
lawlor-pancreas.Rmd
muraro-pancreas.Rmd
tenx-pbmc4k.Rmd
pijuan-embryo.Rmd
bach-mammary.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P3_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/analysis/workflows/${allfiles[$i]} $newfile
done

###################################################
# About files:

allfiles=(
about-the-data.Rmd
about-the-contributors.Rmd
bibliography.Rmd
)

for i in "${!allfiles[@]}"; do 
    newfile=$(printf "P4_W%02d.%s" "$(($i+1))" "${allfiles[$i]}")
    cp ${base}/about/${allfiles[$i]} $newfile
done


###################################################
## Write the DESCRIPTION file automagically 

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


###################################################
## Install/update all libraries

## Prereq packages
R --no-save --slave -e "install.packages('BiocManager'); install.packages('devtools'); install.packages('bookdown')"

## Dependencies
PKGS=$(grep --text -h -r "^library(" ${base} | awk '{FS=" "}{print $1}' | sort | uniq | sed 's/library(/\"/g' | sed 's/)/\",/g' | tr -d '\n\r')
CMD=$(echo "BiocManager::install(c(${PKGS} 'knitr'), ask = FALSE, update = TRUE)") ## add pkg to end line properly

R --no-save --slave -e "${CMD}" 

## Remote packages (manually added)
R --no-save --slave -e "devtools::install_github('stephenturner/msigdf'); devtools::install_github('irrationone/cellassign', ask = FALSE, update = TRUE)"



###################################################
# Build appendix workflow files

R --no-save --slave -e "wf <- list.files('workflows', pattern='Rmd$', full=TRUE, recursive=TRUE); wf <- wf[!grepl('template.Rmd', wf)]; for (x in wf) { rmarkdown::render(x) }"

