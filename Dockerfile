# SHA pin of rocker/geospatial:4.0.2, since rocker tags aren't immutable
FROM rocker/geospatial@sha256:7b0e833cd52753be619030f61ba9e085b45eb9bb13678311da4a55632c3c8c79

# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron

# Add PATH to /etc/profile so it gets picked up by the terminal
RUN echo "PATH=${PATH}" >> /etc/profile
RUN echo "export PATH" >> /etc/profile

# The `rsession` binary that is called by jupyter-rsession-proxy to start R
# doesn't seem to start without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

RUN apt-get update && \
    apt-get -y --quiet --no-install-recommends install \
	apt-transport-https \
	build-essential \
	ca-certificates \
	curl \
	debconf-utils \
	libcurl4-openssl-dev \
	libopenblas-base \
	libreadline-dev \
	libssl-dev \
	lmodern \
	;

RUN curl -o /tmp/ss.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.16.958-amd64.deb && \
    apt -y install /tmp/ss.deb && \
	rm -f /tmp/ss.deb
RUN install -d /srv/shiny-server /etc/service/shiny

# Let's open up the logs within the container.
RUN install -d -o shiny -g shiny -m 777 \
	/var/log/shiny-server \
	/var/lib/shiny-server \
	/var/run/shiny-server

ADD ./shiny-server.conf /etc/shiny-server/shiny-server.conf

# Check https://packagemanager.rstudio.com/client/#/repos/1/packages/A3 first.
# Also installs the dependencies ‘dotCall64', ‘bitops', ‘err', ‘spam', ‘jpeg', ‘rappdirs', ‘checkmate', ‘renv', ‘bibtex'
RUN install2.r --error \
	assertthat \
	backports \
	BalancedSampling \
	base64enc \
	brew \
	caTools \
	checkr \
	commonmark \
	curl \
	data.table \
	devtools \
	doParallel \
	dplyr \
	fields \
	forcats \
	foreach \
	formatR \
	ggdendro \
	ggforce \
	ggformula \
	ggplot2 \
	ggrepel \
	ggridges \
	ggstance \
	git2r \
	gridBase \
	gridExtra \
    gstat \
	highr \
	hms \
	htmlwidgets \
	httpuv \
	httr \
	igraph \
	irlba \
	iterators \
	knitr \
	Lahman \
	latticeExtra \
	leaflet \
	learnr \
	lubridate \
	magrittr \
	manipulate \
	maps \
	maptools \
	markdown \
	memoise \
	mosaic \
	mosaicCore \
	mosaicData \
	ncdf4 \
	nycflights13 \
	openssl \
	pkgmaker \
	plogr \
	png \
	purrr \
	raster \
	RColorBrewer \
	Rcpp \
	RcppEigen \
	RCurl \
	readr \
	registry \
	remotes \
	reshape \
	reshape2 \
	rgdal \
	rgeos \
	rlang \
	rmarkdown \
	RMySQL \
	rngtools \
	roxygen2 \
	rpart \
	rpart.plot \
	rprojroot \
	RSQLite \
	rstudioapi \
	shiny \
	shinydashboard \
	sourcetools \
	sp \
	testthat \
	tibble \
	tidyr \
	tidyverse \
	tinytex \
	tweenr \
	uuid \
	whisker \
	withr \
	XML \
	xml2 \
	yaml \
	;

RUN Rscript -e "devtools::install_github('DataComputing/DataComputing', ref='d5cebba')"

## # 20180111
## RUN Rscript -e "devtools::install_github('lionel-/redpen', ref = '659d571', upgrade_dependencies = FALSE)"
##
# archived as of 2016-11-12
## RUN Rscript -e "local_install(statisticalModeling)"
##
## RUN Rscript -e "devtools::install_github('MarkEdmondson1234/googleAuthR', ref = 'bdecbaf', upgrade_dependencies = FALSE)"
##

RUN apt-get clean && \
	rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Directory for shiny apps and static assets.
VOLUME /srv/shiny-server

ENV SHINY_LOG_LEVEL="TRACE"

EXPOSE 3838

CMD /usr/bin/sudo -u shiny /opt/shiny-server/bin/shiny-server
