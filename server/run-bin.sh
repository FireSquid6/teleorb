#!/usr/bin/env bash
# convineance script to run the binary
# neccessary for bun weirdness
# if the env varialbe "USE_STEAM_RUN" is set to 1, use steam run

if [ "$USE_STEAM_RUN" = "1" ]; then
    steam-run ./bin/server.x86_64
    exit 0
fi


./bin/server.x86_64
