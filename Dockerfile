ARG ALPINE_VERSION
ARG DJBDNS_VERSION
ARG DEAMONTOOLS
ARG UCSPI_TCP
ARG MAINTAINER_NAME
ARG AUTHORNAME
ARG AUTHORS
ARG VERSION
ARG SCHEMAVERSION
ARG NAME
ARG DESCRIPTION
ARG URL
ARG VCS_URL
ARG VENDOR
ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG DOCKERCMD

FROM alpine:${ALPINE_VERSION} AS builder

ARG ALPINE_VERSION
ARG DJBDNS_VERSION
ARG DEAMONTOOLS
ARG UCSPI_TCP
ARG MAINTAINER_NAME
ARG AUTHORNAME
ARG AUTHORS
ARG VERSION
ARG SCHEMAVERSION
ARG NAME
ARG DESCRIPTION
ARG URL
ARG VCS_URL
ARG VENDOR
ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG DOCKERCMD

WORKDIR /package
RUN \
      apk update --no-cache && apk upgrade --no-cache \
      apk add --no-cache --virtual .build-deps gcc g++ make curl openssh-client rsync && \
      apk add --no-cache --virtual perl-net-dns && \
      mkdir /package; \
      cd /package/ && \
      curl --output daemontools-${DEAMONTOOLS}.tar.gz https://cr.yp.to/daemontools/daemontools-${DEAMONTOOLS}.tar.gz && \
      curl -o ucspi-tcp-${UCSPI_TCP}.tar.gz https://cr.yp.to/ucspi-tcp/ucspi-tcp-${UCSPI_TCP}.tar.gz && \
      curl -o djbdns-${DJBDNS_VERSION}.tar.gz https://cr.yp.to/djbdns/djbdns-${DJBDNS_VERSION}.tar.gz && \
      cd /package && \
      ls -la && \
      tar zxvf daemontools-${DEAMONTOOLS}.tar.gz && \
      cd admin/daemontools-${DEAMONTOOLS}/ && \
      echo gcc -O2 -include /usr/include/errno.h > src/conf-cc && \
      ./package/install && \
      cd /package && \
      ls -la && \
      tar zxvf djbdns-${DJBDNS_VERSION}.tar.gz &&  \
      cd djbdns-${DJBDNS_VERSION}/ && \
      echo gcc -O2 -include /usr/include/errno.h > conf-cc && \
      make && \
      make setup check && \
      cd /package && \
      ls -la && \
      tar zxvf ucspi-tcp-${UCSPI_TCP}.tar.gz && \
      cd ucspi-tcp-${UCSPI_TCP}/ && \
      echo gcc -O2 -include /usr/include/errno.h > conf-cc && \
      make && \
      make setup check && \
      apk del .build-deps && \
      rm -rf /var/cache/apk/*

FROM alpine:${ALPINE_VERSION} as djbdns

ARG ALPINE_VERSION
ARG DJBDNS_VERSION
ARG DEAMONTOOLS
ARG UCSPI_TCP
ARG MAINTAINER_NAME
ARG AUTHORNAME
ARG AUTHORS
ARG VERSION
ARG SCHEMAVERSION
ARG NAME
ARG DESCRIPTION
ARG URL
ARG VCS_URL
ARG VENDOR
ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG DOCKERCMD

# Labels.
LABEL maintainer=${MAINTAINER_NAME} \
      version=${VERSION} \
      description=${DESCRIPTION} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name=${NAME} \
      org.label-schema.description=${DESCRIPTION} \
      org.label-schema.usage=${USAGE} \
      org.label-schema.url=${URL} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VSC_REF} \
      org.label-schema.vendor=${VENDOR} \
      org.label-schema.version=${BUILDVERSION} \
      org.label-schema.schema-version=${SCHEMAVERSION} \
      org.label-schema.docker.cmd=${DOCKERCMD} \
      org.label-schema.docker.cmd.devel="" \
      org.label-schema.docker.cmd.test="" \
      org.label-schema.docker.cmd.debug="" \
      org.label-schema.docker.cmd.help="" \
      org.label-schema.docker.params=""

RUN \
      apk update; \
      apk add --no-cache --virtual perl-net-dns; \
      \
      apk add --no-cache --upgrade \
      curl>=8.6.0-r0 \
      libxml2>="2.12.6-r0" \
      --repository https://dl-cdn.alpinelinux.org/alpine/edge/main/ \
      --allow-untrusted ; \
      \
      mkdir -p /package/admin/daemontools-${DEAMONTOOLS}/command/ ;\
      mkdir -p /command; \
      mkdir -p /service; \
      ln -s /package/admin/daemontools-${DEAMONTOOLS} /package/admin/daemontools;

 COPY --from=builder [ \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/envdir", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/envuidgid", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/fghack", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/multilog", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/pgrphack", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/readproctitle", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/setlock", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/setuidgid", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/softlimit", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/supervise", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/svc", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/svok", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/svscan", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/svscanboot", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/svstat", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/tai64n", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/tai64nlocal", \
      "/package/admin/daemontools-${DEAMONTOOLS}/command/"]
COPY --from=builder [ \
      "/command/envdir", \
      "/command/envuidgid", \
      "/command/fghack", \
      "/command/multilog", \
      "/command/pgrphack", \
      "/command/readproctitle", \
      "/command/setlock", \
      "/command/setuidgid", \
      "/command/softlimit", \
      "/command/supervise", \
      "/command/svc", \
      "/command/svok", \
      "/command/svscan", \
      "/command/svscanboot", \
      "/command/svstat", \
      "/command/tai64n", \
      "/command/tai64nlocal", \
      "/command/"]
COPY --from=builder [ \
      "/usr/local/bin/envdir", \
      "/usr/local/bin/envuidgid", \
      "/usr/local/bin/fghack", \
      "/usr/local/bin/multilog", \
      "/usr/local/bin/pgrphack", \
      "/usr/local/bin/readproctitle", \
      "/usr/local/bin/setlock", \
      "/usr/local/bin/setuidgid", \
      "/usr/local/bin/softlimit", \
      "/usr/local/bin/supervise", \
      "/usr/local/bin/svc", \
      "/usr/local/bin/svok", \
      "/usr/local/bin/svscan", \
      "/usr/local/bin/svscanboot", \
      "/usr/local/bin/svstat", \
      "/usr/local/bin/tai64n", \
      "/usr/local/bin/tai64nlocal", \
      "/usr/local/bin/axfr-get", \
      "/usr/local/bin/axfrdns", \
      "/usr/local/bin/axfrdns-conf", \
      "/usr/local/bin/dnscache", \
      "/usr/local/bin/dnscache-conf", \
      "/usr/local/bin/dnsfilter", \
      "/usr/local/bin/dnsip", \
      "/usr/local/bin/dnsipq", \
      "/usr/local/bin/dnsmx", \
      "/usr/local/bin/dnsname", \
      "/usr/local/bin/dnsq", \
      "/usr/local/bin/dnstrace", \
      "/usr/local/bin/dnstracesort", \
      "/usr/local/bin/dnstxt", \
      "/usr/local/bin/pickdns", \
      "/usr/local/bin/pickdns-conf", \
      "/usr/local/bin/pickdns-data", \
      "/usr/local/bin/random-ip", \
      "/usr/local/bin/rbldns", \
      "/usr/local/bin/rbldns-conf", \
      "/usr/local/bin/rbldns-data", \
      "/usr/local/bin/tinydns", \
      "/usr/local/bin/tinydns-conf", \
      "/usr/local/bin/tinydns-data", \
      "/usr/local/bin/tinydns-edit", \
      "/usr/local/bin/tinydns-get", \
      "/usr/local/bin/walldns", \
      "/usr/local/bin/walldns-conf", \
      "/usr/local/bin/"]
COPY --from=builder [ \
      "/usr/local/bin/addcr", \
      "/usr/local/bin/argv0", \
      "/usr/local/bin/date@", \
      "/usr/local/bin/delcr", \
      "/usr/local/bin/finger@", \
      "/usr/local/bin/fixcrio", \
      "/usr/local/bin/http@", \
      "/usr/local/bin/mconnect", \
      "/usr/local/bin/mconnect-io", \
      "/usr/local/bin/rblsmtpd", \
      "/usr/local/bin/recordio", \
      "/usr/local/bin/tcpcat", \
      "/usr/local/bin/tcpcat", \
      "/usr/local/bin/tcpclient", \
      "/usr/local/bin/tcprules", \
      "/usr/local/bin/tcprulescheck", \
      "/usr/local/bin/tcpserver", \
      "/usr/local/bin/who@", \
      "/usr/local/bin/"]

RUN \
      adduser -D tinydns && \
      adduser -D dnslog && \
      adduser -D axfrdns && \
      tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0 && \
      axfrdns-conf axfrdns dnslog /etc/axfrdns /etc/tinydns 0.0.0.0 && \
      if [ ! -L "/etc/tinydns" ]; then ln -s /etc/tinydns /service/tinydns; fi; \
      if [ ! -L "/etc/axfrdns" ]; then ln -s /etc/axfrdns /service/axfrdns; fi

EXPOSE 53/tcp
EXPOSE 53/udp

CMD svscan /service
