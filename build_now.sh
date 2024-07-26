#!/usr/bin/env bash

owd="$(pwd)"
cd "$(dirname "$0")" || exit

BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
VCS_REF="$(git rev-parse --verify HEAD)"

export BUILD_DATE
export VCS_REF

sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE="'"${BUILD_DATE}"'"/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF="'"${VCS_REF}"'"/g' env.hcl

if [ -f env.hcl ]; then
    while IFS= read -r line; do
        export "$line"
    done <env.hcl
fi

DOCKERCMD='docker run -it -d --rm -p 53:53 --name mydjbdns technoboggle/djbdns-alpine:'"${DJBDNS_VERSION//\"/}-${ALPINE_VERSION//\"/}"

sed -i.bu -E 's#DOCKERCMD=".*"#DOCKERCMD="'"${DOCKERCMD//\"/}"'"#g' env.hcl

export DOCKERCMD

if [ -f .perms ]; then
    export $(cat .perms | xargs)
fi

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c ./*

find "$(pwd)" -type d -exec chmod ugo+x {} \;
find "$(pwd)" -type f -exec chmod ugo=wr {} \;
find "$(pwd)" -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;
chmod 0666 .gitignore
chmod 0666 .dockerignore

REGISTRY_URL="https://index.docker.io/v1/"

chmod 0777 hooks/build
echo 'docker login -u='${DOCKER_USER}' -p='${DOCKER_PAT}
docker login $REGISTRY_URL -u $DOCKER_USER -p $DOCKER_PAT

current_builder=''
unload=''

# Test if BUILDER exist and is not empty
if [ ! -z "$BUILDER" ]; then
    #Removing double quotes using the ‘tr’ command
    BUILDER=$(echo "$BUILDER" | tr -d "'\"")
    echo "BUILDER equals :$BUILDER:"
    if [[ $BUILDER == "remote" ]]; then
        ## The way that buildx displays it's ouput has changed so had to rewrite this part which obtains the current builder.
        output=$(docker buildx ls | grep -v '^ ')
        result=$(echo "$output" | awk '{print $1}' | grep -E '^\S+\*($|\s\*)' | head -n 1)
        current_builder=$(echo "$result" | sed 's/[ *]*$//')
        # The following would be for a remote builder
        docker buildx create --driver cloud technoboggle/production
        echo "Buildx will use: cloud-technoboggle-production"
        docker buildx use "cloud-technoboggle-production"
        unload="cloud-technoboggle-production"
    elif [[ $BUILDER == "local" ]]; then
        ## The way that buildx displays it's ouput has changed so had to rewrite this part which obtains the current builder.
        output=$(docker buildx ls | grep -v '^ ')
        result=$(echo "$output" | awk '{print $1}' | grep -E '^\S+\*($|\s\*)' | head -n 1)
        current_builder=$(echo "$result" | sed 's/[ *]*$//')
        # The following is be for a local builder
        docker buildx create --name technoboggle_builder --use --bootstrap
        docker buildx use "technoboggle_builder"
        unload="technoboggle_builder"
    else
        echo "Buildx will use: default"
        docker buildx use "desktop-linux"
    fi
else
    # BUILDER is either missing or empty
    echo "Buildx will use: default"
    docker buildx use "desktop-linux"
fi

docker buildx bake -f docker-bake.hcl -f env.hcl --no-cache --push

sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE=""/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF=""/g' env.hcl
sed -i.bu -E 's/DOCKERCMD=".*"/DOCKERCMD=""/g' env.hcl

rm -f env.hcl.bu

echo "Running the container, using the following command:"
echo "  ${DOCKERCMD}"
echo
docker run -it -d --rm -p 53:53 --name mydjbdns technoboggle/djbdns-alpine:"${DJBDNS_VERSION//\"/}-${ALPINE_VERSION//\"/}"

docker container stop -t 10 mydjbdns

if [ ! -z "$unload" ]; then
    echo "Switching back to builder: ${current_builder}"
    docker buildx use "${current_builder}"
    docker buildx rm "$unload"
fi

cd "$owd" || exit
