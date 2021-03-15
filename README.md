# djbdns-alpine
Docker image for tiny dns server built on alpine


# The following commands to build image and upload to dockerhub
```

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh


docker build -f Dockerfile -t technoboggle/djbdns-alpine:3.13.2_0.0.1 .
docker run -it -d -p 8000:80 --rm --name mydjbdns technoboggle/djbdns-alpine:3.13.2_0.0.1
docker tag technoboggle/djbdns-alpine:3.13.2_0.0.1 technoboggle/djbdns-alpine:latest
docker login
docker push technoboggle/djbdns-alpine:3.13.2_0.0.1
docker push technoboggle/djbdns-alpine:latest
docker container stop -t 10 mydjbdns

