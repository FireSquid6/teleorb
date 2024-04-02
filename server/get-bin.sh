#!/bin/sh


# installs the binary from the github releases
# used by the dockerfile
#
# expects the first positional argument to be the tag
# has the following dependencies:
# - wget
# - unzip


VERSION=$1

echo "Downloading version $VERSION from the github releases"
wget "https://github.com/FireSquid6/teleorb/releases/download/$VERSION/Server.zip"
unzip -d ./bin Server.zip 

rm Server.zip
