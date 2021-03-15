FROM alpine:3.12.3 AS builder
MAINTAINER edward.finlayson@btinternet.com

RUN \
  apk update; \
  apk add --upgrade tinydns

EXPOSE 53
STOPSIGNAL SIGTERM

