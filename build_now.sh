#!/usr/bin/env sh

owd="`pwd`"
cd "$(dirname "$0")"

djbdns_ver="1.05"
alpine_ver="3.16.1"

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh

#docker network create djbdns
docker build -f Dockerfile --progress=plain -t technoboggle/djbdns-alpine:"$djbdns_ver-$alpine_ver" --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF="`git rev-parse --verify HEAD`" --build-arg BUILD_VERSION=0.05 --no-cache .
#--progress=plain 

docker run -it -d --rm -p 53:53 --name mydjbdns technoboggle/djbdns-alpine:"$djbdns_ver-$alpine_ver"

docker tag technoboggle/djbdns-alpine:"$djbdns_ver-$alpine_ver" technoboggle/djbdns-alpine:latest
docker login
docker push technoboggle/djbdns-alpine:"$djbdns_ver-$alpine_ver"
docker push technoboggle/djbdns-alpine:latest
#docker container stop -t 10 mydjbdns

cd "$owd"
