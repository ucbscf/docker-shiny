FROM buildpack-deps:focal-scm

# Set up common env variables
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ENV OUR_USER myshiny
ENV OUR_UID 1000

RUN adduser --disabled-password --gecos "Default user" ${OUR_USER}

# Create user owned R libs dir
# This lets users temporarily install packages
ENV R_LIBS_USER /opt/r
RUN install -d -o ${OUR_USER} -g ${OUR_USER} ${R_LIBS_USER}

RUN apt-get -qq update --yes && \
    apt-get -qq install --yes --no-install-recommends \
            tar \
            vim \
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
            sudo \
            locales > /dev/null

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install R packages
# Our pre-built R packages from rspm are built against system libs in focal
# rstan takes forever to compile from source, and needs libnodejs
# We don't want R 4.1 yet - the graphics protocol version it has is incompatible
# with the version of RStudio we use. So we pin R to 4.0.5
ENV R_VERSION=4.0.5-1.2004.0
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" > /etc/apt/sources.list.d/cran.list
RUN apt-get update -qq --yes > /dev/null && \
    apt-get install --yes -qq \
    r-base-core=${R_VERSION} \
    r-base-dev=${R_VERSION} \
    r-cran-littler=0.3.11-1.2004.0 > /dev/null && \
    apt-mark hold r-base-core r-base-dev r-cran-littler

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

# Set CRAN mirror to rspm before we install anything
COPY Rprofile.site /usr/lib/R/etc/Rprofile.site

# R_LIBS_USER is set by default in /etc/R/Renviron, which RStudio loads.
# We uncomment the default, and set what we wanna - so it picks up
# the packages we install. Without this, RStudio doesn't see the packages
# that R does.
# Stolen from https://github.com/jupyterhub/repo2docker/blob/6a07a48b2df48168685bb0f993d2a12bd86e23bf/repo2docker/buildpacks/r.py
# To try fight https://community.rstudio.com/t/timedatectl-had-status-1/72060,
# which shows up sometimes when trying to install packages that want the TZ
# timedatectl expects systemd running, which isn't true in our containers
RUN sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
    echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron && \
    echo "TZ=${TZ}" >> /etc/R/Renviron

# package build dependencies
# libglu1 is for Biobase
# libproj and libgdal are for paciorek's setVegComp-leaflet
RUN apt-get update -qq --yes > /dev/null && \
    apt-get install --yes -qq \
    libglu1-mesa \
    libglu1-mesa-dev \
    libproj15 \
    libgdal26

# function to install user libs
COPY user-libs.R /tmp/user-libs.R

# Install all our base R packages
COPY install.R  /tmp/install.R
RUN /tmp/install.R && \
    rm -rf /tmp/downloaded_packages

RUN mkdir -p /tmp/r-packages

COPY r-packages/paciorek.r /tmp/r-packages/
RUN r /tmp/r-packages/paciorek.r

COPY r-packages/alucas.r /tmp/r-packages/
RUN r /tmp/r-packages/alucas.r

COPY r-packages/koenvdberge.r /tmp/r-packages/
RUN r /tmp/r-packages/koenvdberge.r

COPY r-packages/bosf.r /tmp/r-packages/
RUN r /tmp/r-packages/bosf.r

# cleanup
RUN apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Directory for shiny apps and static assets.
VOLUME /srv/shiny-server

ENV SHINY_LOG_LEVEL="TRACE"

EXPOSE 3838

CMD /usr/bin/sudo -u shiny /opt/shiny-server/bin/shiny-server
