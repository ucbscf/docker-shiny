FROM ubuntu:16.04

ARG SITE_SHINY_USER_ID
ENV SHINY_USER_ID=$SITE_SHINY_USER_ID

# Necessary for add-apt-repository
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

############ This came from Jupyter hub install-stat28
RUN set -e
RUN apt-get -y --quiet --no-install-recommends install apt-transport-https

ENV R_REPO="https://mran.revolutionanalytics.com/snapshot/2017-02-16"
ENV MRAN_KEY="06F90DE5381BA480"
ENV GPG_KEY_SERVER="keyserver.ubuntu.com"
ENV U_CODE="jessie-cran3"

RUN echo "deb ${R_REPO}/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/mran.list
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${MRAN_KEY}
RUN gpg -a --export ${MRAN_KEY} | apt-key add -
RUN echo -n | openssl s_client -connect mran.revolutionanalytics.com:443 | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
    tee '/usr/local/share/ca-certificates/mran.revolutionanalytics.com.crt'

RUN update-ca-certificates

# Oracle Java 8 repo
RUN add-apt-repository -y ppa:webupd8team/java

RUN ( \
	echo debconf shared/accepted-oracle-license-v1-1 select true ; \
    echo debconf shared/accepted-oracle-license-v1-1 seen true ; \
	) | debconf-set-selections

# Packages, please note that R version should be 3.3.2 version
RUN apt-get update

RUN apt-get -y --quiet --allow-unauthenticated --no-install-recommends install \
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
	r-cran-evaluate \
	r-cran-digest \
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
	oracle-java7-installer \
	oracle-java8-installer \
	;

RUN if [ -z $SHINY_USER_ID ]; then useradd -m shiny; else useradd -m -u $SHINY_USER_ID shiny; fi

ENV RCRAN=${R_REPO}

# Install shiny
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')" && \
	update-locale && \
	wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.1.834-amd64.deb && \
	dpkg -i --force-depends shiny-server-1.5.1.834-amd64.deb && \
	rm shiny-server-1.5.1.834-amd64.deb && \
	mkdir -p /etc/service/shiny /var/run/shiny-server \
		/srv/shiny-server/examples && \
	cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples/. 

RUN Rscript -e "install.packages('formatR', repos='${RCRAN}')"
RUN Rscript -e "install.packages('devtools', repos='${RCRAN}')"
RUN Rscript -e "install.packages('uuid', repos='${RCRAN}')"
RUN Rscript -e "install.packages('rmarkdown', repos='${RCRAN}')"
RUN Rscript -e "install.packages('fields', repos='${RCRAN}')"
RUN Rscript -e "install.packages('ggplot2', repos='${RCRAN}')"
RUN Rscript -e "install.packages('grid', repos='${RCRAN}')"
RUN Rscript -e "install.packages('gridExtra', repos='${RCRAN}')"
RUN Rscript -e "install.packages('maps', repos='${RCRAN}')"
RUN Rscript -e "install.packages('maptools', repos='${RCRAN}')"
RUN Rscript -e "install.packages('ncdf4', repos='${RCRAN}')"
RUN Rscript -e "install.packages('raster', repos='${RCRAN}')"
RUN Rscript -e "install.packages('RColorBrewer', repos='${RCRAN}')"
RUN Rscript -e "install.packages('reshape', repos='${RCRAN}')"
RUN Rscript -e "install.packages('reshape2', repos='${RCRAN}')"
RUN Rscript -e "install.packages('rgdal', repos='${RCRAN}')"
RUN Rscript -e "install.packages('sp', repos='${RCRAN}')"
RUN Rscript -e "install.packages('mosaicData', repos='${RCRAN}')"
RUN Rscript -e "install.packages('rprojroot',repos=c('https://cran.cnr.berkeley.edu'))"
RUN Rscript -e "install.packages('googlesheets',repos=c('https://cran.cnr.berkeley.edu'))"
RUN Rscript -e "install.packages('statisticalModeling', repos=c('https://cran.cnr.berkeley.edu'))"
RUN Rscript -e "library('devtools'); install_github('rstudio/tutor')"
RUN Rscript -e "library('devtools'); install_github('dtkaplan/checkr')"
RUN Rscript -e "library('devtools'); install_github('DataComputing/DataComputing')"
RUN Rscript -e "install.packages('leaflet', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('XML', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('RCurl', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('DBI', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('RSQLite', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('nycflights13', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('Lahman', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('RMySQL', repos='${RCRAN}')" 
RUN Rscript -e "install.packages('ggdendro', repos='${R_REPO}')"
RUN Rscript -e "install.packages('rpart', repos='${R_REPO}')"
RUN Rscript -e "install.packages('statisticalModeling', repos='${R_REPO}')"
RUN Rscript -e "install.packages('rpart.plot', repos='${R_REPO}')"
RUN Rscript -e "install.packages('stats', repos='${R_REPO}')"
RUN Rscript -e "install.packages('mosaicData', repos='${R_REPO}')"

ADD ./etc/shiny-server/shiny-server.conf /etc/shiny-server/shiny-server.conf

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container
# run the first time .. using a flag to don't 
# run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d /var/log/cron/config /var/lib/shiny-server

# Let's open up the logs within the container.
RUN chown -R shiny:shiny /var/log/shiny-server \
	/var/lib/shiny-server \
	/var/run/shiny-server
RUN chmod 777 /var/run/shiny-server \
	/var/log/shiny-server \
	/var/lib/shiny-server
RUN sed -i '113 a <h2><a href="./examples/">Other examples of Shiny application</a> </h2>' /srv/shiny-server/index.html

RUN apt-get clean \
	&& rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Directory for shiny apps and static assets.
VOLUME /srv/shiny-server

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside
# of the server. 
EXPOSE 3838

# Set Shiny log level
ENV SHINY_LOG_LEVEL="TRACE"

CMD /usr/bin/sudo -u shiny /opt/shiny-server/bin/shiny-server
