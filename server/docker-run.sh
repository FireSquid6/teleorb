#!/bin/sh



docker run -p 3000:3000 -p 3412:3412 registry.digitalocean.com/teleorb/server:$1
