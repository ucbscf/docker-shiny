#!/usr/bin/env r

# Install devtools so we can install versioned packages
install.packages("devtools")

source("/tmp/user-libs.R")

dplyr_packages = c(
  "dplyr", "1.0.2",
  "arrow", "2.0.0",
  "dbplyr", "2.0.0",
  "dtplyr", "1.0.1",
  "nycflights13", "1.0.1",
  "Lahman", "8.0-0",
  "RSQLite", "2.2.1"
)

base_packages = c(
  "assertthat", "0.2.1",
  "base64enc", "0.1-3",
  "BiocManager", "1.30.10",
  "brew", "1.0-6",
  "checkr", "0.5.0",
  "commonmark", "1.7",
  "curl", "4.3",
  "data.table", "1.13.6",
  "forcats", "0.5.0",
  "ggplot2", "3.3.3",
  "git2r", "0.27.1",
  "gstat", "2.1-0",
  "highr", "0.8",
  "hms", "0.5.3",
  "htmlwidgets", "1.5.3",
  "httpuv", "1.5.4",
  "httr", "1.4.2",
  "knitr", "1.30",
  "leaflet", "2.0.3",
  "learnr", "0.10.1",
  "lubridate", "1.7.9.2",
  "magrittr", "2.0.1",
  "maptools", "1.0-2",
  "markdown", "1.1",
  "memoise", "1.1.0",
  "ncdf4", "1.17",
  "openssl", "1.4.3",
  "png", "0.1-7",
  "purrr", "0.3.4",
  "raster", "3.4-5",
  "Rcpp", "1.0.7",
  "readr", "1.4.0",
  "remotes", "2.4.0",
  "reshape", "0.8.8",
  "rgeos", "0.5-5",
  "rgl", "0.103.5",
  "rlang", "0.4.10",
  "rmarkdown", "2.6",
  "roxygen2", "7.1.1",
  "rpart", "4.1-15",
  "rprojroot", "2.0.2",
  "rstudioapi", "0.13",
  "shiny", "1.5.0",
  "sp", "1.4-4",
  "testthat", "3.0.1",
  "tibble", "3.0.4",
  "tidyr", "1.1.2",
  "tidyverse", "1.3.0",
  "uuid", "0.1-4",
  "whisker", "0.4",
  "withr", "2.3.0",
  "xml2", "1.3.2",
  "yaml", "2.2.1"
)

user_libs_install_version("Base packages", base_packages)
user_libs_install_version("dplyr packages", dplyr_packages)

# Check https://packagemanager.rstudio.com/client/#/repos/1/packages/A3 first.
# Also installs the dependencies ‘dotCall64', ‘bitops', ‘err', ‘spam', ‘jpeg', ‘rappdirs', ‘checkmate', ‘renv', ‘bibtex'
## RUN install2.r --error \
## 	backports \
## 	BalancedSampling \
## 	caTools \
## 	doParallel \
## 	fields \
## 	foreach \
## 	formatR \
## 	ggdendro \
## 	ggforce \
## 	ggformula \
## 	ggrepel \
## 	ggridges \
## 	ggstance \
## 	gridBase \
## 	gridExtra \
## 	Hmisc \
## 	igraph \
## 	irlba \
## 	iterators \
## 	latticeExtra \
## 	manipulate \
## 	maps \
## 	mosaic \
## 	mosaicCore \
## 	mosaicData \
## 	pkgmaker \
## 	plogr \
## 	RColorBrewer \
## 	RcppEigen \
## 	RCurl \
## 	registry \
## 	reshape2 \
## 	rgdal \
## 	RMySQL \
## 	rngtools \
## 	rpart.plot \
## 	shinydashboard \
## 	sourcetools \
## 	tinytex \
## 	tweenr \
## 	wesanderson \
## 	XML \
## 	;
