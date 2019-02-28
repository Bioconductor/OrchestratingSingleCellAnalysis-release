## version 3 of figure 1 - Bioconductor usage

library(BiocPkgTools)
library(tidyverse)
library(lubridate)
##library(cowplot)
library(ggsci)
library(scales)

## process package stats
pkg_stats <- BiocPkgTools::biocDownloadStats()
pkg_stats <- pkg_stats[pkg_stats$Month != 'all' & pkg_stats$repo == 'Software', ] # exclude the all time points
pkg_stats$Date <- as.Date(
    paste0(
        '1', tolower(as.character(pkg_stats$Month)), as.character(pkg_stats$Year)
    ), "%d%b%Y"
)
pkg_stats <- pkg_stats[, c(-2, -3)]
pkg_stats <- pkg_stats[pkg_stats$Date < as.Date('2019-02-15'), ] # or use Sys.Date()
pkg_stats <- select(pkg_stats, -repo)

## process package metadata
pkg_metadata <- BiocPkgTools::biocPkgList()

pkg_metadata_sc <- pkg_metadata %>%
    select(Package, biocViews, git_last_commit_date) %>%
    mutate(git_last_commit_date = as.Date(git_last_commit_date)) %>%
    ## Assay - SingleCell or Other
    mutate(
        Assay = map_chr(biocViews, function(x) {
            ifelse("SingleCell" %in% x, "SingleCell", "Other")
        }),
        Seq = map_chr(biocViews, function(x) {
            x <- x[!grepl("LinkageDisequilibrium|GenomicSequence|MultipleSequenceAlignment|SequenceMatching", x)]
            ifelse(sum(grepl("seq", x, ignore.case = TRUE) > 0), "Seq", "Other")
        })
    ) %>%
    mutate(Assay = ifelse(is.na(Assay), FALSE, Assay),
           Seq = ifelse(is.na(Seq), FALSE, Seq)) %>%
    ## Git commit - within last year or not
    mutate(Status = map_chr(git_last_commit_date, function(x) {
        ifelse(x > as.Date('2018-11-01') & x != as.Date('2019-01-04'), 'active', 'stable')
    })) %>%
    ## trim down
    select(-git_last_commit_date) %>%
    ## Relevel factors
    mutate(Assay = fct_relevel(Assay, "SingleCell"),
           Status = fct_relevel(Status, "active"))
    
## Append metadata 
pkg_tbl <- inner_join(pkg_stats, pkg_metadata_sc, by = "Package")


## 1. Growth of Bioconductor over 10 years ================================================
## all packages -------------------------------------------------------------
pkg_su <- pkg_stats %>%
    group_by(Date) %>%
    summarise(total_distinct_IPs = sum(Nb_of_distinct_IPs),
              total_downloads = sum(Nb_of_downloads),
              total_packages = n())

pkg_su %>%
    filter(Date != as.Date('2019-02-01')) %>%
    ggplot(aes(x = Date, y = total_distinct_IPs)) +
    geom_smooth(se = TRUE, fill = 'grey90',
                level = 0.75, span = 0.1,
                size = 1, colour = pal_npg()(8)[1]) +
    scale_y_continuous(breaks = seq(0, max(pkg_su$total_distinct_IPs), by = 100000)) +
    theme_classic() +
    labs(x = "", y = "Total Distinct IPs") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y")

## Separating by seq vs non-seq ----------------------------------------------
pkg_cu <- pkg_tbl %>%
    group_by(Date, Seq) %>%
    summarise(total_distinct_IPs = sum(Nb_of_distinct_IPs),
              total_downloads = sum(Nb_of_downloads),
              total_packages = n()) %>%
    mutate(Seq = fct_relevel(Seq, "Seq")) %>%
    arrange(Date, Seq) %>%
    group_by(Date) %>%
    mutate(cumulative_distinct_IPs = cumsum(total_distinct_IPs),
           max = cumulative_distinct_IPs,
           min = lag(max),
           min = ifelse(is.na(min), 0, min))

## Ribbon plot
pkg_cu %>%
    filter(Date != as.Date('2019-02-01')) %>%
    filter(Seq == 'Seq') %>%
    ggplot(aes(x = Date, y = max, ymax = max, ymin = min, group = Seq, colour = Seq, fill = Seq)) +
    ##geom_ribbon(colour = 'black', size = 0.25) +
    geom_smooth(span = 0.1) +
    scale_y_continuous(breaks = seq(0, max(pkg_su$total_distinct_IPs), by = 100000)) +
    theme_classic() +
    labs(x = "", y = "Total Distinct IPs") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    coord_cartesian(expand = FALSE) +
    scale_fill_manual(values = pal_npg()(2)) +
    theme(legend.position = 'none', axis.text.x = element_text(hjust = 1, angle = 30))


## Seq with single-cell highlighted
tmp <- pkg_tbl %>%
    filter(Seq == 'Seq') %>%
    filter(Date < as.Date('2019-02-01')) %>%
    group_by(Date, Assay) %>%
    summarise(total_distinct_IPs = sum(Nb_of_distinct_IPs),
              total_downloads = sum(Nb_of_downloads),
              total_packages = n()) 
    
tmp %>%
    ggplot(aes(x = Date, y = total_distinct_IPs, group = Assay, colour = Assay)) +
    geom_smooth(span = 0.1) +
    coord_cartesian(expand = FALSE)




## 2. By Technology within Seq  ============================================================

top_terms_seq <- pkg_tbl %>%
    select(Package, biocViews, Seq) %>%
    unique() %>%
    filter(Seq == 'Seq') %>%
    select(biocViews) %>%
    unnest() %>%
    group_by(biocViews) %>%
    count() %>% arrange(desc(n))

pkg_tbl %>%
    filter(Nb_of_distinct_IPs > 0, Nb_of_downloads > 0,
           Seq == 'Seq') %>%
    unnest() %>%
    group_by(Date, Assay) %>%
    count() %>%
    ggplot(aes(x = Date, y = n, group = Assay, colour = Assay)) +
    geom_smooth(span = 0.1)


pkg_tbl %>%
    filter(Seq == 'Seq')



##    filter(biocViews == 'SingleCell') %>%
    group_by(Date) %>%
    count() %>%

    ggplot(aes(x = Date, y = Nb_of_distinct_IPs, group = Package)) +
    geom_line()
    





top_terms_seq$biocViews[1:25]    

terms <- c('RNASeq', 'Epigenetics', 'Visualization',
          'ImmunoOncology', 'ChIPSeq', 'DifferentialExpression',
          'SingleCell')

pkg_tbl %>%
    filter(Nb_of_distinct_IPs > 0, Seq == 'Seq') %>%
    select(Package, biocViews, Assay, Seq, Status) %>%
    unnest() %>%
    unique() %>%
    filter(biocViews %in% terms)






pkg_tbl %>%
    group_by(Assay, Seq, Date) %>%
    summarise(total_distinct_IPs = sum(Nb_of_distinct_IPs),
              total_downloads = sum(Nb_of_downloads),
              total_packages = n()) %>%
    filter(Date != as.Date('2019-02-01')) %>%
    filter(Date > as.Date('2015-01-01')) %>%
    ggplot(aes(x = Date, y = total_downloads, colour = interaction(Assay, Seq))) +
    ## geom_smooth(se = TRUE, fill = 'grey90',
    ##             level = 0.75, span = 0.1,
    ##             size = 1, colour = pal_npg()(8)[1]) +
    geom_line() +
    geom_hline(yintercept = 3000) +
    scale_y_continuous(breaks = seq(0, max(pkg_su$total_distinct_IPs), by = 100000)) +
    coord_cartesian(expand = FALSE) +
    theme_classic() +
    labs(x = "Date", y = "Total Distinct IPs")





## Append metadata regarding views
pkg_metadata <- BiocPkgTools::biocPkgList()

pkg_metadata_sc <- pkg_metadata %>%
    select(Package, biocViews, git_last_commit_date) %>%
    mutate(git_last_commit_date = as.Date(git_last_commit_date)) %>%
    ## Assay - SingleCell or Other
    mutate(
        Assay = map_chr(biocViews, function(x) {
            ifelse("SingleCell" %in% x, "SingleCell", "Other")
        }),
        Seq = map_chr(biocViews, function(x) {
            ifelse(sum(grepl("seq", x, ignore.case = TRUE) > 0), "Seq", "Other")
        })
    ) %>%
    mutate(Assay = ifelse(is.na(Assay), FALSE, Assay),
           Seq = ifelse(is.na(Seq), FALSE, Seq)) %>%
    ## Git commit - within last year or not
    mutate(Status = map_chr(git_last_commit_date, function(x) {
        ifelse(x > as.Date('2018-11-01') & x != as.Date('2019-01-04'), 'active', 'stable')
    })) %>%
    ## trim down
    select(-git_last_commit_date) %>%
    ## Relevel factors
    mutate(Assay = fct_relevel(Assay, "SingleCell"),
           Status = fct_relevel(Status, "active"))
    

pkg_tbl <- inner_join(pkg_stats, pkg_metadata_sc, by = "Package")


table(pkg_metadata_sc[, c('Assay', 'Status', "Seq")])










mat <- pkg_tbl %>%
    select(Assay, Status, Package, Date, Nb_of_distinct_IPs) %>%
    arrange(Assay, Status, Package, Date) %>%
    spread(Date, Nb_of_distinct_IPs) %>%
    mutate_at(vars(-Assay, -Status, -Package), ~ ifelse(is.na(.), 0, .)) 
#    mutate(Assay = ifelse(Assay != "SingleCell", "Other", Assay))

## Apply a cumulative sum across the rows to position each package and gather
tbl_cs <- mat %>%
    mutate_at(vars(`2009-01-01`:`2019-01-01`), cumsum) %>%
    gather(Date, Nb_of_distinct_IPs, -Assay, -Status, -Package) 
#    arrange(desc(Nb_of_distinct_IPs))


## Group by technology
tbl_su <- tbl_cs %>%
    group_by(Assay, Status, Date) %>%
    summarise(min = min(Nb_of_distinct_IPs),
              max = max(Nb_of_distinct_IPs))
#              num = sum(Nb_of_distinct_IPs > 0))

tbl_su <- tbl_cs %>%
    group_by(Assay, Date) %>%
    summarise(num = sum(Nb_of_distinct_IPs > 0))



tbl_su %>%
    ggplot(aes(x = Date,
               ymax = max, ymin = min,
               group = interaction(Assay, Status),
               fill = interaction(Assay, Status))) +
    geom_ribbon()

tbl_su %>%
    ggplot(aes(x = Date,
               y = num,
               group = Assay, 
               colour = Assay)) +
    geom_line()





tbl_cs %>%
##    filter(Assay == 'SingleCell') %>%
    ggplot(aes(x = Date, y = Nb_of_distinct_IPs,
               colour = Assay)) +# , group = Package)) +
##    geom_line(size = 1) +
     geom_ribbon(aes(ymax = Nb_of_distinct_IPs, ymin = 0, colour = Assay, fill = Assay),
                 alpha = 0.1, size = 0) +
#    scale_colour_manual(values = colours_terms) +
#    scale_fill_manual(values = colours_terms) +
##    coord_cartesian(expand = FALSE) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
    scale_x_discrete(breaks = paste0(2009:2019, '-01-01')) +
    labs(x = '', y = 'Number of Distinct IPs')

pkg_tbl %>%
    ggplot(aes(x = Date, y = Nb_of_distinct_IPs, colour = Assay, group = Package)) +
#    geom_ribbon(aes(ymax = Nb_of_distinct_IPs, ymin = 0, fill = Assay), alpha = 0.1, size = 0) +
    geom_line(alpha = 0.5) +
#    scale_colour_manual(values = colours_terms) +
#    scale_fill_manual(values = colours_terms) +    
##    scale_y_log10() +
    facet_wrap(~ Assay, scales = "free_y")



## poi_l <- map(terms, .pullPkgData, pkgData = pkg_metadata)
.pullPkgData <- function(term, pkgData) {
    pkgData %>%
        dplyr::filter(str_detect(biocViews, !!term)) %>% 
        dplyr::pull(Package)
}


names(poi_l) <- terms
poi_df <- poi_l %>% reshape2::melt(value.name = 'Package')
colnames(poi_df)[2] <- 'Assay'

pkg_tbl <- inner_join(pkg_stats, poi_df, by = 'Package') %>%
    arrange(Package, Date) %>%
    select(-repo)
