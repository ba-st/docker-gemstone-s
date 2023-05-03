# Base image to run GemStone on docker, you must provide the required gemstone.key

# Based on https://github.com/jgfoster/DockerForGemStone/blob/master/GS-CE-Starter-3.4.2/Dockerfile

# Runs on a multi-stage build: https://docs.docker.com/develop/develop-images/multistage-build/
# - Prepare a base image with all dependencies installed
# - Prepare gemstone environment on stage 1: builder
# - Copy prepared environment onto stage 2, the final image, to reduce final docker image size

## Prepare base image to use docker cache during build
FROM debian:11-slim AS base

ENV SHELL=/bin/bash \
    GS_USER=gemstone \
    GS_UID=1001 \
    GS_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=/opt/gemstone \
    GEMSTONE=/opt/gemstone/product \
    PATH=/opt/gemstone/product/bin:$PATH \
    GS_FORCE_CLEAN_LOG_FILE_DELETE=true

RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    gosu \
    libldap-2.4-2:i386 \
    libstdc++6:i386 \
    libx11-6:i386 \
    locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && echo "en_US.ISO-8859-15 ISO-8859-15" >> /etc/locale.gen \
  && locale-gen \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd --uid ${GS_UID} --gid ${GS_GID} --home-dir ${HOME} --no-create-home --no-user-group ${GS_USER} \
  ;



## Download GemStone from GemTalk Systems
FROM alpine:3.10 as download

ARG GS_ARCH
ARG GS_MAJOR_VERSION
ARG GS_VERSION
ENV GEMSTONE=/opt/gemstone/product
RUN wget https://downloads.gemtalksystems.com/pub/GemStoneS/${GS_VERSION}/GemStone${GS_VERSION}-${GS_ARCH}.Linux.zip -O /tmp/GemStone${GS_VERSION}-${GS_ARCH}.Linux.zip
RUN mkdir -p /opt/gemstone \
  && unzip -qq /tmp/GemStone${GS_VERSION}-${GS_ARCH}.Linux.zip -d /tmp \
  && mv /tmp/GemStone${GS_VERSION}-${GS_ARCH}.Linux ${GEMSTONE}

COPY gemstone.sh /opt/gemstone/gemstone.sh
COPY entrypoint.sh /opt/gemstone/entrypoint.sh

# Setup: create required directories and remove unnecesary files
RUN true \
  && mkdir -p \
    /opt/gemstone/conf/ \
    /opt/gemstone/data/ \
    /opt/gemstone/locks/ \
    /opt/gemstone/log/ \
  && sed -r 's|\$GEMSTONE/data|/opt/gemstone/data|g' ${GEMSTONE}/data/system.conf > /opt/gemstone/conf/system.conf \
  && rm -rf \
    ${GEMSTONE}/bin/obsolete/ \
    ${GEMSTONE}/data/ \
    ${GEMSTONE}/doc/ \
    ${GEMSTONE}/examples/ \
    ${GEMSTONE}/include/ \
    ${GEMSTONE}/install/ \
    ;

# Use the same .conf file for system and stone
RUN ln -s /opt/gemstone/conf/system.conf /opt/gemstone/conf/gemserver${GS_MAJOR_VERSION}.conf
# We place .conf files on /opt/gemstone/conf, not on $GEMSTONE/data, link the default location to the new location
RUN ln -s /opt/gemstone/conf/ ${GEMSTONE}/data



## Prepare the final image
FROM base
LABEL maintainer="serpi90@gmail.com"

ARG GS_MAJOR_VERSION
ENV NETLDI=netldi${GS_MAJOR_VERSION}
ENV NETLDI_PORT=50384
ENV STONE=gemserver${GS_MAJOR_VERSION}
ENV STONE_PORT=50385

COPY --from=download --chown=gemstone:users /opt/gemstone /opt/gemstone
RUN ln -s ${GEMSTONE}/bin/gemsetup.sh /etc/profile.d/gemstone.sh

WORKDIR /opt/gemstone
VOLUME /opt/gemstone/data/
CMD ["./entrypoint.sh"]
