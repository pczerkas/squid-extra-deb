ARG DISTRO
ARG RELEASE
FROM ${DISTRO}:${RELEASE}

# defines target squid version
ARG DISTRO
ARG RELEASE
ARG TARGET_SQUID_VERSION
ARG NEW_SQUID_VERSION

# defines squid proxy to be used during build
ARG SQUID_HOST
ARG SQUID_HTTP_PORT
ARG SQUID_HTTPS_PORT
ARG NO_PROXY

# to disable interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

ARG PRIVATE_GPG_KEY
ARG PRIVATE_GPG_KEY_PASSPHRASE
ARG INSTALL_TOOLCHAIN_PPA
ARG TOOLCHAIN_CXX_VERSION

ENV http_proxy=http://$SQUID_HOST:$SQUID_HTTP_PORT
ENV https_proxy=http://$SQUID_HOST:$SQUID_HTTPS_PORT
ENV no_proxy=$NO_PROXY
ENV HOME /root

SHELL ["/bin/bash", "-c"]
USER root
WORKDIR $HOME

# fixes "Hash Sum mismatch" error in apt
RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99fixbadproxy \
    && echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
    && echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99fixbadproxy

# configure system-wide proxy
#TODO: copy this file from remote repository?
COPY configure-squid-ca.sh \
    /opt/bin/
RUN apt-get -y update
RUN [ ! -z "$SQUID_HOST" ] \
    && /opt/bin/configure-squid-ca.sh \
    && echo "export http_proxy=http://$SQUID_HOST:$SQUID_HTTP_PORT" >> /etc/profile \
    && echo "export https_proxy=http://$SQUID_HOST:$SQUID_HTTPS_PORT" >> /etc/profile \
    && echo "export no_proxy='$NO_PROXY'" >> /etc/profile \
    && mkdir -p /etc/apt/apt.conf.d \
    && echo "Acquire::http::Proxy \"http://$SQUID_HOST:$SQUID_HTTP_PORT\";" > /etc/apt/apt.conf.d/00proxy \
    && echo "Acquire::https::Proxy \"http://$SQUID_HOST:$SQUID_HTTPS_PORT\";" >> /etc/apt/apt.conf.d/00proxy \
    && cat /etc/apt/apt.conf.d/00proxy \
    || [ -z "$SQUID_HOST" ] && true

# install toolchain ppa
RUN [ ! -z "$INSTALL_TOOLCHAIN_PPA" ] \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get -y update \
    && apt-get -y install gcc-$TOOLCHAIN_CXX_VERSION g++-$TOOLCHAIN_CXX_VERSION \
    || [ -z "$INSTALL_TOOLCHAIN_PPA" ] && true

# install deb build tools
RUN apt-get -y install ubuntu-dev-tools

# install mk-build-deps dependencies
RUN apt-get -y install devscripts equivs

# install squid build dependencies (separate steps to cache it)
RUN cp /etc/apt/sources.list /etc/apt/sources.list~ \
	&& sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
	&& apt-get -y update \
    && apt-get -y build-dep squid
COPY docker/install-build-dependencies.sh \
    docker/$DISTRO-$RELEASE/squid-$TARGET_SQUID_VERSION/insert-source-patches.sh \
    /opt/bin/
RUN chmod +x /opt/bin/install-build-dependencies.sh /opt/bin/insert-source-patches.sh

COPY patches ./patches
COPY squid-deb.sh ./squid-deb.sh

# build squid
RUN ./squid-deb.sh "$DISTRO" "$RELEASE" "$TARGET_SQUID_VERSION" "$NEW_SQUID_VERSION" "$PRIVATE_GPG_KEY" "$PRIVATE_GPG_KEY_PASSPHRASE"
