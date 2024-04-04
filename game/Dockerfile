# Build Stage
FROM ubuntu:latest as build

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y unzip wget zip

ENV GODOT_VERSION="4.2"
ENV RELEASE_NAME="stable"
ENV GODOT_GAME_NAME="teleorb"
ENV EXPORT_PRESET="Server"

RUN mkdir /buildspace && mkdir /server
WORKDIR /buildspace

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip

RUN mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip

RUN godot -e --quit --display-driver headless

RUN godot --headless --export-release ${EXPORT_PRESET} ${GODOT_GAME_NAME} 
RUN ls
RUN mv ${GODOT_GAME_NAME} /server/

# Runtime Stage
FROM alpine:latest as runtime
COPY --from=build /server /server

WORKDIR /server
CMD ./${GODOT_GAME_NAME}
