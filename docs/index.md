--- 
title: "Orchestrating Single-Cell Analysis with Bioconductor"
author: ["Robert A. Amezquita", "Stephanie C. Hicks"]
date: "2019-03-06"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
favicon: "favicon.ico"
description: "Online companion to 'Orchestrating Single-Cell Analysis with Bioconductor' manuscript by the Bioconductor team."
---

# Welcome {-}

<a href="https://bioconductor.org"><img src="cover.png" width="200" alt="Bioconductor Sticker" align="right" style="margin: 0 1em 0 1em" /></a> 

This is the website for __"Orchestrating Single-Cell Analysis with Bioconductor"__, a book that teaches users some common workflows for the analysis of single-cell RNA-seq data (scRNA-seq). This book will teach you how to make use of cutting-edge Bioconductor tools to process, analyze, visualize, and explore scRNA-seq data. Additionally, it serves as an online companion for the manuscript __"Orchestrating Single-Cell Analysis with Bioconductor"__. 

While we focus here on scRNA-seq data, a newer technology that profiles transcriptomes at the single-cell level, many of the tools, conventions, and analysis strategies utilized throughout this book are broadly applicable to other types of assays. By learning the grammar of Bioconductor workflows, we hope to provide you a starting point for the exploration of your own data, whether it be scRNA-seq or otherwise. 

This book is organized into two parts. In the _Preamble_, we introduce the book and dive into resources for learning R and Bioconductor (both at a beginner and developer level). Part I ends with a tutorial for a key data infrastructure, the _SingleCellExperiment_ class, that is used throughout Bioconductor for single-cell analysis and in the subsequent section. This section can be safely skipped by readers already familiar with R.

The second part, _Workflows_, provides templates for performing single-cell RNA-seq analyses across various objectives. In these templates, we take various datasets from raw data through to preprocessing and finally to the objective at hand, using packages that are referred to in the main manuscript.

---

The book is written in [RMarkdown](https://rmarkdown.rstudio.com) with [bookdown](https://bookdown.org). OSCA is a collaborative effort, supported by various folks from the Bioconductor team who have contributed workflows, fixes, and improvements.

This website is (and will always be) __free to use__, and is licensed under the [Creative Commons Attribution-NonCommercial-NoDerivs 3.0](http://creativecommons.org/licenses/by-nc-nd/3.0/us/) License.



