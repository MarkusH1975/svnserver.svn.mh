#############################
# Markus Hilsenbeck
# svnserver with svn:// protocol

FROM ubuntu:22.04

LABEL Maintainer="Markus Hilsenbeck" \
      E-Mail="markus.dev@hilsi.de" \
      GitHub="https://github.com/MarkusH1975/"


# Add Tini as init process running as pid 1
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "-w", "-v", "--"]
      

# volume: create directories and links
RUN mkdir -p /volume/monitorix.conf && \
    ln -s /volume/monitorix.conf/ /etc/monitorix

RUN mkdir -p /volume/monitorix.data && \
    ln -s /volume/monitorix.data/ /var/lib/monitorix

RUN mkdir -p /volume/svnrepo


# Installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install --no-install-recommends -y apt-utils && \
    apt-get install --no-install-recommends -y \
    vim nano sudo wget curl unzip lsof psmisc\
    locales \
    cron \
    ca-certificates \
    monitorix \
    subversion \
    && apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


# generate some locales
RUN locale-gen \
    de_DE.UTF-8 \
    en_GB.UTF-8 \
    en_US.UTF-8


# volume: set permissions
RUN chmod -Rfv 777 /volume/monitorix.conf
RUN chmod -Rfv 777 /volume/monitorix.data
RUN chmod -Rfv 777 /volume/svnrepo

# volume: copy everything to the template folder for automatic generation
RUN cp -fvra /volume /volume.template

#Ports exposed by the container
# monitorix: http://localhost:8080/monitorix/
EXPOSE 8080
# svn protocol: svn://
EXPOSE 3690

# Environment variables: select services to be started
ENV ENABLE_CRON=false \
    ENABLE_MONITORIX=true \
    ENABLE_SVNSERVER=true 

# To force docker build to invalidate cache from now on, to be sure entrypoint.sh is updated
# docker build --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) -t svnserver.apache .
ARG CACHE_DATE
RUN echo "\n* Docker image build time: $CACHE_DATE"

# add startup script
COPY entrypoint.sh /

# CMD will be executed by tini 
CMD ["/bin/bash", "/entrypoint.sh"]
