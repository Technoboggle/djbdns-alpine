# The following commands to build image and upload to dockerhub
```

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh


# for more build detail add the following argument:  --progress=plain

docker build -f Dockerfile -t technoboggle/djbdns-alpine:1.05-3.16.1 --build-arg buildDate=$(date +'%Y-%m-%d') --no-cache --progress=plain .
docker run -it -d -p 53:53 --rm --name dns technoboggle/djbdns-alpine:1.05-3.16.1
docker tag technoboggle/djbdns-alpine:1.05-3.16.1 technoboggle/djbdns-alpine:latest
docker login
docker push technoboggle/djbdns-alpine:1.05-3.16.1
docker push technoboggle/djbdns-alpine:latest
docker container stop -t 10 dns
