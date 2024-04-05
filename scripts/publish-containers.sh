#!/bin/sh

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "No version provided. exiting"
    exit 1
fi

# Game container
docker build --pull -t firesquid/teleorb-server:$VERSION game
docker push firesquid/teleorb-server:$VERSION
