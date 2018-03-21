FROM ubuntu:17.10

ENV MRAN_KEY="51716619E084DAB9"
ENV GPG_KEY_SERVER="keyserver.ubuntu.com"
ENV SHINY_SERVER_DEB="shiny-server-1.5.6.875-amd64.deb"

RUN apt-get update
RUN apt-get -y --quiet --no-install-recommends install \
	apt-transport-https \
	build-essential \
	ca-certificates \
	cron \
	curl \
	debconf-utils \
	dirmngr \
	gcc \
	gdebi-core \
	libapparmor1 \
	libcairo-dev \
	libcurl4-openssl-dev \
	libcurl4-openssl-dev \
	libgdal-dev \
	libopenblas-base \
	libreadline-dev \
	libssl1.0.0 \
	libssl-dev \
	libxml2-dev \
	libzmq3-dev \
	lmodern \
	lsb-release \
	pkg-config \
	sudo \
	wget \
	;

# MRAN snapshot repo
RUN echo "deb https://mran.revolutionanalytics.com/snapshot/2018-03-18/bin/linux/ubuntu artful/" > /etc/apt/sources.list.d/mran.list
RUN gpg --keyserver ${GPG_KEY_SERVER} --recv-keys ${MRAN_KEY}
RUN gpg -a --export ${MRAN_KEY} | apt-key add -

RUN apt-get update

RUN apt-get -y --quiet --no-install-recommends install \
	r-recommended \
	r-base-core \
	r-base-dev \
	r-base \
	littler \
	;

# Check https://packages.ubuntu.com/artful/r-cran-{package} before adding.
RUN apt-get -y --quiet --no-install-recommends install \
	r-cran-backports \
	r-cran-base64enc \
	r-cran-brew \
	r-cran-catools \
	r-cran-curl \
	r-cran-doparallel \
	r-cran-dplyr \
	r-cran-fields \
	r-cran-foreach \
	r-cran-formatr \
	r-cran-ggplot2 \
	r-cran-gridbase \
	r-cran-gridextra \
	r-cran-highr \
	r-cran-htmlwidgets \
	r-cran-httpuv \
	r-cran-httr \
	r-cran-igraph \
	r-cran-irlba \
	r-cran-iterators \
	r-cran-knitr \
	r-cran-latticeextra \
	r-cran-lubridate \
	r-cran-magrittr \
	r-cran-maps \
	r-cran-maptools \
	r-cran-markdown \
	r-cran-ncdf4 \
	r-cran-openssl \
	r-cran-pkgmaker \
	r-cran-plogr \
	r-cran-png \
	r-cran-raster \
	r-cran-rcolorbrewer \
	r-cran-rcpp \
	r-cran-rcurl \
	r-cran-registry \
	r-cran-reshape \
	r-cran-reshape2 \
	r-cran-rmysql \
	r-cran-rngtools \
	r-cran-rpart \
	r-cran-rsqlite \
	r-cran-sourcetools \
	r-cran-sp \
	r-cran-testthat \
	r-cran-tidyr \
	r-cran-uuid \
	r-cran-withr \
	r-cran-xml \
	r-cran-xml2 \
	r-cran-yaml \
	;

# packages in bionic:
# assertthat, devtools, git2r, hms, memoise, readr, rlang, rprojroot,
# rstudioapi, whisker

RUN useradd -m shiny

ADD Rprofile.site /etc/R/Rprofile.site

# The debian/ubuntu r-cran-shiny package symlinks various javascript assets
# in /usr/lib/R/site-library/shiny/. However, shiny refuses to serve[1] these
# assets which results in 404 errors. Packages of 1.0.5 and up have a patch[2]
# which overcomes this but they depend on Debian r-base-core which depends on
# an r-api- metapackage.
#
# [1] https://github.com/rstudio/shiny/issues/1064
# [2] https://sources.debian.org/src/r-cran-shiny/1.0.5+dfsg-4/debian/patches/fix_utils_resolve_for_debian.patch/
#
# We'll just install shiny from source. r-cran- packages that depend on the
# r-cran-shiny package will also have to be installed from source, including
# r-cran-miniui r-cran-shinyjs r-cran-shinydashboard

RUN Rscript -e "local_install(shiny)"
RUN Rscript -e "local_install(shinyjs)"

RUN wget https://download3.rstudio.org/ubuntu-12.04/x86_64/${SHINY_SERVER_DEB}
RUN dpkg -i --force-depends ${SHINY_SERVER_DEB} && \
	rm ${SHINY_SERVER_DEB}
RUN install -d /srv/shiny-server /etc/service/shiny

RUN Rscript -e "local_install('devtools')"
#RUN Rscript -e "local_install('magrittr')"
RUN Rscript -e "install.packages('rlang')"

RUN Rscript -e "devtools::install_github('lionel-/redpen', ref = '659d571', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('rstudio/rmarkdown', ref = '7669d66', upgrade_dependencies = FALSE)"
# 0.1.0
RUN Rscript -e "devtools::install_github('rstudio/learnr', ref = '0909f74', upgrade_dependencies = FALSE)"

RUN Rscript -e "devtools::install_github('dtkaplan/checkr', ref = 'e806220', upgrade_dependencies = FALSE)"

RUN Rscript -e "devtools::install_github('DataComputing/DataComputing', ref='d5cebba', upgrade_dependencies = FALSE)"
RUN Rscript -e "local_install(shinydashboard)"
RUN Rscript -e "local_install(grid)"
RUN Rscript -e "local_install(mosaicData)"
RUN Rscript -e "local_install(statisticalModeling)"
RUN Rscript -e "local_install(methods)"
RUN Rscript -e "local_install(manipulate)"
RUN Rscript -e "local_install(leaflet)"
RUN Rscript -e "local_install(nycflights13)"
RUN Rscript -e "local_install(Lahman)"
RUN Rscript -e "local_install(ggdendro)"
RUN Rscript -e "local_install(rpart.plot)"
RUN Rscript -e "local_install(rgeos)"
RUN Rscript -e "local_install(commonmark)"
RUN Rscript -e "local_install(roxygen2)"

# Required by googleAuthR
RUN Rscript -e "devtools::install_github('cran/assertthat', ref = '6dce79d', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('cran/httr',       ref = 'b37cfa3', upgrade_dependencies = FALSE)"

RUN Rscript -e "devtools::install_github('MarkEdmondson1234/googleID', ref='d52905e', upgrade_dependencies = FALSE)"

# googleAuthR requires memoise >= 1.1.0 so we can't use artful's r-cran-memoise
RUN Rscript -e "devtools::install_github('r-lib/memoise', ref = 'v.1.1.0', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('MarkEdmondson1234/googleAuthR', ref = 'bdecbaf', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('cran/rgdal', ref = '16ed596', upgrade_dependencies = FALSE)"


ADD ./shiny-server.conf /etc/shiny-server/shiny-server.conf

##startup scripts
#Pre-config scrip that maybe need to be run one time only when the container
# run the first time .. using a flag to don't
# run it again ... use for conf for service ... when run the first time ...
#RUN mkdir -p /etc/my_init.d /var/log/cron/config

# Let's open up the logs within the container.
RUN install -d -o shiny -g shiny -m 777 \
	/var/log/shiny-server \
	/var/lib/shiny-server \
	/var/run/shiny-server

RUN apt-get clean && \
	rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Directory for shiny apps and static assets.
VOLUME /srv/shiny-server

ENV SHINY_LOG_LEVEL="TRACE"

EXPOSE 3838

CMD /usr/bin/sudo -u shiny /opt/shiny-server/bin/shiny-server
