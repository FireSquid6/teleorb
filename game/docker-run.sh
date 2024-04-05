#!/bin/sh

docker run -d -p 4000:4000 -p 3412:3412 registry.digitalocean.com/teleorb/server:$1
