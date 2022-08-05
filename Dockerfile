FROM alpine:3.16.1 AS builder
LABEL net.technoboggle.authorname="Edward Finlayson" \
      net.technoboggle.authors="edward.finlayson@btinternet.com" \
      net.technoboggle.version="0.1" \
      net.technoboggle.description="This image builds a DNS server based on the \
djbns package by Dr. Daniel J. Bernstein." \
      net.technoboggle.buildDate=$buildDate

WORKDIR /package
RUN \
 apk update; \
 apk add --no-cache --virtual .build-deps gcc g++ make curl openssh-client rsync; \
 apk add --no-cache --virtual perl-net-dns; \
 mkdir /package; \
 cd /package/; \
 curl --output daemontools-0.76.tar.gz https://cr.yp.to/daemontools/daemontools-0.76.tar.gz; \
 curl -o ucspi-tcp-0.88.tar.gz https://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz; \
 curl -o djbdns-1.05.tar.gz https://cr.yp.to/djbdns/djbdns-1.05.tar.gz; \
 cd /package; \
 ls -la; \
 tar zxvf daemontools-0.76.tar.gz; \
 cd admin/daemontools-0.76/; \
 echo gcc -O2 -include /usr/include/errno.h > src/conf-cc; \
 ./package/install; \
 cd /package; \
 ls -la; \
 tar zxvf ucspi-tcp-0.88.tar.gz; \
 cd ucspi-tcp-0.88/; \
 echo gcc -O2 -include /usr/include/errno.h > conf-cc; \
 make; \
 make setup check; \
 cd /package; \
 ls -la; \
 tar zxvf djbdns-1.05.tar.gz;  \
 cd djbdns-1.05/; \
 echo gcc -O2 -include /usr/include/errno.h > conf-cc; \
 make; \
 make setup check; \
 apk del .build-deps;

FROM alpine:3.16.1
RUN \
  apk add --no-cache --virtual perl-net-dns; \
  mkdir -p /package/admin/daemontools-0.76/command/ ;\
  mkdir -p /command; \
  mkdir -p /service;
COPY --from=builder ["/package/admin/daemontools-0.76/command/envdir", "/package/admin/daemontools-0.76/command/multilog", "/package/admin/daemontools-0.76/command/setlock", "/package/admin/daemontools-0.76/command/supervise", "/package/admin/daemontools-0.76/command/svscan", "/package/admin/daemontools-0.76/command/tai64n", "/package/admin/daemontools-0.76/command/envuidgid", "/package/admin/daemontools-0.76/command/pgrphack", "/package/admin/daemontools-0.76/command/setuidgid", "/package/admin/daemontools-0.76/command/svc", "/package/admin/daemontools-0.76/command/svscanboot", "/package/admin/daemontools-0.76/command/tai64nlocal", "/package/admin/daemontools-0.76/command/fghack", "/package/admin/daemontools-0.76/command/readproctitle", "/package/admin/daemontools-0.76/command/softlimit", "/package/admin/daemontools-0.76/command/svok", "/package/admin/daemontools-0.76/command/svstat", "/package/admin/daemontools-0.76/command/"]
COPY --from=builder ["/usr/local/bin/envdir", "/usr/local/bin/multilog", "/usr/local/bin/setlock", "/usr/local/bin/supervise", "/usr/local/bin/svscan", "/usr/local/bin/tai64n", "/usr/local/bin/envuidgid", "/usr/local/bin/pgrphack", "/usr/local/bin/setuidgid", "/usr/local/bin/svc", "/usr/local/bin/svscanboot", "/usr/local/bin/tai64nlocal", "/usr/local/bin/fghack", "/usr/local/bin/readproctitle", "/usr/local/bin/softlimit", "/usr/local/bin/svok", "/usr/local/bin/svstat", "/usr/local/bin/"]
COPY --from=builder /service /
COPY --from=builder ["/command/envdir", "/command/multilog", "/command/setlock", "/command/supervise", "/command/svscan", "/command/tai64n", "/command/envuidgid", "/command/pgrphack", "/command/setuidgid", "/command/svc", "/command/svscanboot", "/command/tai64nlocal", "/command/fghack", "/command/readproctitle", "/command/softlimit", "/command/svok", "/command/svstat", "/command/"]
COPY --from=builder ["/usr/local/bin/addcr", "/usr/local/bin/argv0", "/usr/local/bin/date@", "/usr/local/bin/delcr", "/usr/local/bin/finger@", "/usr/local/bin/fixcrio", "/usr/local/bin/http@", "/usr/local/bin/mconnect", "/usr/local/bin/mconnect-io", "/usr/local/bin/rblsmtpd", "/usr/local/bin/recordio", "/usr/local/bin/tcpcat", "/usr/local/bin/tcpcat", "/usr/local/bin/tcpclient", "/usr/local/bin/tcprules", "/usr/local/bin/tcprulescheck", "/usr/local/bin/tcpserver", "/usr/local/bin/who@", "/usr/local/bin/"]
COPY --from=builder ["/usr/local/bin/axfr-get", "/usr/local/bin/axfrdns", "/usr/local/bin/axfrdns-conf", "/usr/local/bin/dnscache", "/usr/local/bin/dnscache-conf", "/usr/local/bin/dnsfilter", "/usr/local/bin/dnsip", "/usr/local/bin/dnsipq", "/usr/local/bin/dnsmx", "/usr/local/bin/dnsname", "/usr/local/bin/dnsq", "/usr/local/bin/dnstrace", "/usr/local/bin/dnstracesort", "/usr/local/bin/dnstxt", "/usr/local/bin/pickdns", "/usr/local/bin/pickdns-conf", "/usr/local/bin/pickdns-data", "/usr/local/bin/random-ip", "/usr/local/bin/rbldns", "/usr/local/bin/rbldns-conf", "/usr/local/bin/rbldns-data", "/usr/local/bin/tinydns", "/usr/local/bin/tinydns-conf", "/usr/local/bin/tinydns-data", "/usr/local/bin/tinydns-edit", "/usr/local/bin/tinydns-get", "/usr/local/bin/walldns", "/usr/local/bin/walldns-conf", "/usr/local/bin/"]
RUN \
 adduser -D tinydns; \
 adduser -D dnslog; \
 tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0; \
 ln -s /etc/tinydns /service/tinydns; 

RUN \
 adduser -D axfrdns; \
 axfrdns-conf axfrdns dnslog /etc/axfrdns /etc/tinydns 0.0.0.0; \
 ln -s /etc/axfrdns /service/axfrdns

EXPOSE 53/tcp
EXPOSE 53/udp

CMD svscan /service

