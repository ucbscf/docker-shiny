FROM ubuntu:17.04

ARG SITE_SHINY_USER_ID
ENV SHINY_USER_ID=$SITE_SHINY_USER_ID
ENV MRAN_KEY="51716619E084DAB9"
ENV GPG_KEY_SERVER="keyserver.ubuntu.com"
ENV SHINY_SERVER_DEB="shiny-server-1.5.3.838-amd64.deb"

RUN apt-get update

# MRAN snapshot repo
RUN echo "deb http://mran.revolutionanalytics.com/snapshot/2017-08-17/bin/linux/ubuntu zesty/" > /etc/apt/sources.list.d/mran.list
# To fetch remote key
RUN apt-get -y --quiet --no-install-recommends install \
	dirmngr
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${MRAN_KEY}
RUN gpg -a --export ${MRAN_KEY} | apt-key add -

# Oracle Java 8 repo
#RUN add-apt-repository -y ppa:webupd8team/java

RUN apt-get update

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN apt-get -y --quiet --no-install-recommends install \
	build-essential \
	gcc \
	curl \
	wget \
	pkg-config \
	libcurl4-openssl-dev \
	libreadline-dev \
	libssl-dev \
	libzmq3-dev \
	r-base-core \
	r-base-dev \
	r-base \
	r-recommended \
	libopenblas-base \
	r-cran-testthat \
	littler \
	gdebi-core \  
	debconf-utils \	
	libapparmor1 \
	sudo \
	cron \
	libssl1.0.0 \
	libssl-dev \
	libxml2-dev \
	libcairo-dev \
	libcurl4-openssl-dev \
	lmodern \
	libmariadb-client-lgpl-dev \
    ;

#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer 

RUN if [ -z $SHINY_USER_ID ]; then useradd -m shiny; else useradd -m -u $SHINY_USER_ID shiny; fi

ADD Rprofile.site /etc/R/Rprofile.site

# This is Shiny stuff, leave this alone
RUN Rscript -e "local_install('shiny')"
RUN wget https://download3.rstudio.org/ubuntu-12.04/x86_64/${SHINY_SERVER_DEB} && \
	dpkg -i --force-depends ${SHINY_SERVER_DEB} && \
	rm ${SHINY_SERVER_DEB} && \
	mkdir -p /srv/shiny-server /etc/service/shiny /var/run/shiny-server /srv/shiny-server/examples && \
	cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples/. \
    ;

RUN Rscript -e "local_install('devtools')"

RUN Rscript -e "devtools::install_github('rstudio/rmarkdown', ref = '7669d66', upgrade_dependencies = FALSE)"
# 0.1.0
RUN Rscript -e "devtools::install_github('rstudio/learnr', ref = '0909f74', upgrade_dependencies = FALSE)"

RUN Rscript -e "devtools::install_github('dtkaplan/checkr', ref = 'ab2a3e0', upgrade_dependencies = FALSE)"

RUN Rscript -e "devtools::install_github('DataComputing/DataComputing', ref='d5cebba', upgrade_dependencies = FALSE)"

RUN Rscript -e "local_install(formatR)"
RUN Rscript -e "local_install(uuid)"
RUN Rscript -e "local_install(fields)"
RUN Rscript -e "local_install(ggplot2)"
RUN Rscript -e "local_install(grid)"
RUN Rscript -e "local_install(gridExtra)"
RUN Rscript -e "local_install(maps)"
RUN Rscript -e "local_install(maptools)"
RUN Rscript -e "local_install(ncdf4)"
RUN Rscript -e "local_install(raster)"
RUN Rscript -e "local_install(RColorBrewer)"
RUN Rscript -e "local_install(reshape)"
RUN Rscript -e "local_install(reshape2)"
RUN Rscript -e "local_install(rgdal)"
RUN Rscript -e "local_install(sp)"
RUN Rscript -e "local_install(mosaicData)"
RUN Rscript -e "local_install(statisticalModeling)"
RUN Rscript -e "local_install(methods)"
RUN Rscript -e "local_install(lubridate)"
RUN Rscript -e "local_install(igraph)"
RUN Rscript -e "local_install(doParallel)"
RUN Rscript -e "local_install(foreach)"
RUN Rscript -e "local_install(iterators)"
RUN Rscript -e "local_install(gridBase)"
RUN Rscript -e "local_install(pkgmaker)"
RUN Rscript -e "local_install(registry)"
RUN Rscript -e "local_install(rngtools)"
RUN Rscript -e "local_install(irlba)"
RUN Rscript -e "local_install(manipulate)"
RUN Rscript -e "local_install(leaflet)"
RUN Rscript -e "local_install(XML)"
RUN Rscript -e "local_install(RCurl)"
RUN Rscript -e "local_install(plogr)"
RUN Rscript -e "local_install(RSQLite)"
RUN Rscript -e "local_install(nycflights13)"
RUN Rscript -e "local_install(Lahman)"
RUN Rscript -e "local_install(RMySQL)"
RUN Rscript -e "local_install(ggdendro)"
RUN Rscript -e "local_install(rpart)"
RUN Rscript -e "local_install(rpart.plot)"
RUN Rscript -e "local_install(rpart.plot)"

RUN Rscript -e "devtools::install_github('hadley/testthat', ref = 'c7e8330', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('r-lib/memoise', ref = 'v.1.1.0', upgrade_dependencies = FALSE)"
RUN Rscript -e "devtools::install_github('MarkEdmondson1234/googleAuthR', ref = '5800f07', upgrade_dependencies = FALSE)"

ADD ./etc/shiny-server/shiny-server.conf /etc/shiny-server/shiny-server.conf

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container
# run the first time .. using a flag to don't 
# run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d /var/log/cron/config

# Let's open up the logs within the container.
RUN install -d -o shiny -g shiny -m 777 \
	/var/log/shiny-server \
	/var/lib/shiny-server \
	/var/run/shiny-server

RUN apt-get clean && \
	rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Directory for shiny apps and static assets.
VOLUME /srv/shiny-server

EXPOSE 3838

# Set Shiny log level
ENV SHINY_LOG_LEVEL="TRACE"

CMD /usr/bin/sudo -u shiny /opt/shiny-server/bin/shiny-server