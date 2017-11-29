FROM debian:jessie-slim

#
# Original credit goes to:
# https://github.com/westerus/isc-kea/blob/master/base/Dockerfile
#

MAINTAINER  mkinsley <michael@mwkinsley.com>


ARG PKG_FLAGS_COMMON="-qq -y"
ARG PKG_FLAGS_PERSISTANT="${PKG_FLAGS_COMMON} --no-install-recommends"
ARG PKG_FLAGS_DEV="${PKG_FLAGS_COMMON} --no-install-recommends"
ARG PKGUPDATE="apt-get ${PKG_FLAGS_COMMON} update"
ARG PKGUPGRADE="apt-get ${PKG_FLAGS_COMMON} dist-upgrade"
ARG PKGCLEAN="apt-get ${PKG_FLAGS_COMMON} autoclean"
ARG DELTEMP="rm -rf /var/tmp/* /tmp/* /usr/src/*"
ARG PKGINSTALL="apt-get ${PKG_FLAGS_PERSISTANT} install"
ARG PKGREMOVE="apt-get ${PKG_FLAGS_COMMON} remove"
ARG PKGPURGE="apt-get ${PKG_FLAGS_COMMON} purge"
ARG LIBREMOVE="dpkg -r --force-depends"
ARG LIBPURGE="dpkg -P --force-depends"

ENV DEBIAN_FRONTEND="noninteractive" TERM="xterm"

ENV KEAURL="https://github.com/isc-projects/kea" KEABRANCH="v1_3_0" KEACONF="/etc/kea/kea.conf"

WORKDIR /usr/src/kea

RUN  $PKGUPDATE \
  && $PKGUPGRADE \
  && $PKGINSTALL libtool \
        autoconf \
        g++ \
        make \
        automake \
        libssl-dev \
        libpq-dev \
        liblog4cplus-dev \
        libboost-dev \
        libboost-system-dev \
        libmysqlclient-dev \
        postgresql-server-dev-all \
        git \
        ca-certificates
RUN git clone $KEAURL --depth 1 -b $KEABRANCH . \
  && autoreconf --install --force --warnings='all' \
  && ./configure --prefix='/opt/kea' \
      --sbindir='${exec_prefix}/bin' \
      --sysconfdir='/etc' \
      --localstatedir='/var' \
      --with-openssl \
      --with-boost-lib-dir='/usr/lib/x86_64-linux-gnu' \
      --with-dhcp-mysql \
      --with-dhcp-pgsql \
  && make -j8 \
  && make install \
  && $LIBPURGE postgresql-server-dev-all \
        libmysqlclient-dev \
        libboost-system-dev \
        libboost-dev \
        liblog4cplus-dev \
  && $PKGPURGE autoconf \
        g++ \
        make \
        git \
        automake \
  && $PKGCLEAN \
  && $DELTEMP

FROM debian:jessie-slim
COPY --from=0 /opt/kea /opt/kea
COPY --from=0 /etc/kea /etc/kea
