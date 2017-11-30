FROM debian:stretch-slim

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
ARG NUMPROCS="-j 48"
ENV KEAURL="https://github.com/isc-projects/kea" KEABRANCH="v1_3_0" KEACONF="/etc/kea/kea.conf"
ENV KEA_LIB=/usr/local/lib
ENV KEA_INCLUDE=/usr/local/include/kea
ENV HOOKS_LIB_DIR=/usr/local/lib/hooks

WORKDIR /usr/src/kea

RUN  $PKGUPDATE \
  && $PKGUPGRADE \
  && $PKGINSTALL libtool \
        autoconf \
        g++ \
        make \
        automake \
        libssl-dev \
        liblog4cplus-dev \
        libboost-dev \
        libboost-system-dev \
        git \
        ca-certificates \
  && git clone $KEAURL --depth 1 -b $KEABRANCH . \
  && autoreconf --install --force --warnings='all' \
  && ./configure \
      --sbindir='${exec_prefix}/bin' \
      --sysconfdir='/etc' \
      --localstatedir='/var' \
      --with-openssl \
      --with-boost-lib-dir='/usr/lib/x86_64-linux-gnu' \
  && make ${NUMPROCS} \
  && make install \
  && ldconfig \
  && echo ${HOOKS_LIB_DIR} > /etc/ld.so.conf.d/kea_hooks \
  && git clone https://github.com/zorun/kea-hook-runscript.git \
  && cd kea-hook-runscript \
  && make ${NUMPROCS} \
  && cp kea-hook-runscript.so ${HOOKS_LIB_DIR} \
  && $LIBPURGE libboost-system-dev \
        libboost-dev \
        liblog4cplus-dev \
  && $PKGPURGE autoconf \
        g++ \
        make \
        git \
        automake \
  && $PKGCLEAN \
  && $DELTEMP
EXPOSE 67/udp
CMD ["/usr/bin/kea-dhcp4","-d","-c","/etc/kea/kea-dhcp4.conf"]
#
#
# RUN git clone https://github.com/zorun/kea-hook-runscript.git .
# RUN make -j8
#
#
# FROM debian:stretch-slim
# ARG PKG_FLAGS_COMMON="-qq -y"
# ARG PKG_FLAGS_PERSISTANT="${PKG_FLAGS_COMMON} --no-install-recommends"
# ARG PKG_FLAGS_DEV="${PKG_FLAGS_COMMON} --no-install-recommends"
# ARG PKGUPDATE="apt-get ${PKG_FLAGS_COMMON} update"
# ARG PKGUPGRADE="apt-get ${PKG_FLAGS_COMMON} dist-upgrade"
# ARG PKGINSTALL="apt-get ${PKG_FLAGS_PERSISTANT} install"
# ARG PKGCLEAN="apt-get ${PKG_FLAGS_COMMON} autoclean"
# ARG DELTEMP="rm -rf /var/tmp/* /tmp/* /usr/src/*"
# RUN  $PKGUPDATE \
#   && $PKGINSTALL kea-dev libssl-dev \
#       libpq-dev \
#       liblog4cplus-dev \
#       libboost-dev \
#       libboost-system-dev \
#       default-libmysqlclient-dev \
#   && $PKGCLEAN \
#   && $DELTEMP
# COPY --from=0 /opt/kea /opt/kea
# COPY --from=0 /etc/kea /etc/kea
# COPY --from=1 /tmp/kea-hook-runscript.so /opt/kea/lib/hooks/
# COPY --from=0 /opt/kea/lib/*.so* /usr/lib/x86_64-linux-gnu/
# RUN mkdir -p /var/kea /var/run/kea
# EXPOSE 67/udp
# CMD ["/opt/kea/bin/kea-dhcp4","-d","-c","/etc/kea/kea-dhcp4.conf"]
