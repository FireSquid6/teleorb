#!/bin/sh

# convineance script to build the docker image
# takes the first positional argument as the tag

VERSION=$1

# if version is not provided, exit
if [ -z "$VERSION" ]; then
    echo "No version provided"
    exit 1
fi

docker build --pull --build-arg BINARY_TAG=$VERSION -t registry.digitalocean.com/teleorb/server:$VERSION .
