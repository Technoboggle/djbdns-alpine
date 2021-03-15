FROM alpine:3.13.2
MAINTAINER Edward Finlayson version: 0.2

RUN \
 apk update; \
 apk add --no-cache --virtual .build-deps \
   gcc \
   g++ \
   make \
   curl \
   openssh-client \
   rsync; \
 apk add --no-cache --virtual \
   perl-net-dns; \
\
#RUN \
 mkdir /package; \
 cd /package/; \
 curl --output daemontools-0.76.tar.gz https://cr.yp.to/daemontools/daemontools-0.76.tar.gz; \
 curl -o ucspi-tcp-0.88.tar.gz https://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz; \
 curl -o djbdns-1.05.tar.gz https://cr.yp.to/djbdns/djbdns-1.05.tar.gz; \
\
#RUN \
 cd /package; \
 ls -la; \
 tar zxvf daemontools-0.76.tar.gz; \
 cd admin/daemontools-0.76/; \
 echo gcc -O2 -include /usr/include/errno.h > src/conf-cc; \
 ./package/install; \
\
#RUN \
 cd /package; \
 ls -la; \
 tar zxvf ucspi-tcp-0.88.tar.gz; \
 cd ucspi-tcp-0.88/; \
 echo gcc -O2 -include /usr/include/errno.h > conf-cc; \
 make; \
 make setup check; \
\
#RUN \
 cd /package; \
 ls -la; \
 tar zxvf djbdns-1.05.tar.gz;  \
 cd djbdns-1.05/; \
 echo gcc -O2 -include /usr/include/errno.h > conf-cc; \
 make; \
 make setup check; \
 cd /; \
 apk del --no-network .build-deps; \
 rm -rf /package; \
\
#RUN \
 adduser -D tinydns; \
 adduser -D dnslog; \
 tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0; \
 ln -s /etc/tinydns /service/tinydns; \
\
#RUN \
 adduser -D axfrdns; \
 axfrdns-conf axfrdns dnslog /etc/axfrdns /etc/tinydns 0.0.0.0; \
 ln -s /etc/axfrdns /service/axfrdns

EXPOSE 53/tcp
EXPOSE 53/udp

CMD svscan /service

