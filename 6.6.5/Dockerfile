# Base image to run GemStone 6.6.5 on docker, you must provide the required gemstone.key

# Based on https://github.com/jgfoster/DockerForGemStone/blob/master/GS-CE-Starter-3.4.2/Dockerfile

# Runs on a multi-stage build: https://docs.docker.com/develop/develop-images/multistage-build/
# 1- Prepare gemstone environment on stage 1: builder
# 2- Copy prepared environment onto stage 2, the final image, to reduce final docker image size

## Stage 1 prepare GS environment

FROM debian:9-slim AS builder

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

# Install users and dependencies, must be the same command as in stage 2 in order to use docker cache
RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install --assume-yes --no-install-recommends libstdc++6:i386 libx11-6:i386 libldap-2.4-2:i386 locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd --uid ${GS_UID} --gid ${GS_GID} --home-dir ${HOME} --no-create-home --no-user-group ${GS_USER} \
  && true

# Install tools needed for installantion, do not bother to remove them because it's a multistage build.
RUN apt-get update \
  && apt-get install --assume-yes --no-install-recommends unzip

# Download and install under $GEMSTONE => /opt/gemstone/product
ADD --chown=gemstone:users https://downloads.gemtalksystems.com/pub/GemStoneS/6.6.5/GemStone6.6.5-i686.Linux.zip /tmp/
RUN mkdir -p /opt/gemstone \
  && cd /tmp/ \
  && unzip GemStone6.6.5-i686.Linux.zip \
  && mv GemStone6.6.5-i686.Linux ${GEMSTONE}

COPY gemstone.sh /opt/gemstone/gemstone.sh

# Set gemstone environment variables as global
RUN ln --symbolic ${GEMSTONE}/bin/gemsetup.sh /etc/profile.d/gemstone.sh

# Setup, create required directories and remove unnecesary files
RUN true \
  && mkdir --parents \
    /opt/gemstone/conf/ \
    /opt/gemstone/data/ \
    /opt/gemstone/locks/ \
    /opt/gemstone/log/ \
  && mv ${GEMSTONE}/bin/extent0.dbf /opt/gemstone/data/extent0.dbf \
  && mv ${GEMSTONE}/data/system.conf /opt/gemstone/conf/system.conf \
  && rm --recursive --force \
    ${GEMSTONE}/bin/obsolete/ \
    ${GEMSTONE}/data/ \
    ${GEMSTONE}/doc/ \
    ${GEMSTONE}/examples/ \
    ${GEMSTONE}/include/ \
    ${GEMSTONE}/install/ \
  && touch /opt/gemstone/conf/gemserver66.conf \
  && echo "netldi66 50384/tcp #GemStone" >> /etc/services \
  && echo "gemserver66 50385/tcp #GemStone" >> /etc/services \
  && chown --recursive ${GS_UID}:${GS_GID} /opt/gemstone

## Stage 2 - Final image

FROM debian:9-slim

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
  && apt-get install --assume-yes --no-install-recommends libstdc++6:i386 libx11-6:i386 libldap-2.4-2:i386 locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd --uid ${GS_UID} --gid ${GS_GID} --home-dir ${HOME} --no-create-home --no-user-group ${GS_USER} \
  && true

COPY --from=builder --chown=gemstone:users /opt/gemstone /opt/gemstone
COPY --from=builder /etc/services /etc/services

VOLUME /opt/gemstone/data/
USER ${GS_UID}:${GS_GID}
WORKDIR /opt/gemstone
LABEL maintainer="serpi90@gmail.com"
CMD ["./gemstone.sh"]
