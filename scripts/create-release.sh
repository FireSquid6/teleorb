#!/bin/sh


VERSION=$1
if [ -z "$VERSION" ]; then
    echo "No version provided. exiting"
    exit 1
fi


git tag -a $1 -m "version $VERSION"
git push origin $VERSION



# CI for exporting game is handled by github actions
# The game is published to github releases

# publishes containers to their respective registries
publish-containers.sh $VERSION

