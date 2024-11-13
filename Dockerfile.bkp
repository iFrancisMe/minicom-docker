# syntax=docker/dockerfile:1

ARG RELEASE_TAG=latest

FROM alpine

WORKDIR /root

RUN apk add --no-cache abuild linux-headers build-base sudo curl ncurses-dev gettext-dev
#RUN apk add --no-cache tio

RUN wget https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/minicom/APKBUILD

RUN sed -i "s/--sysconfdir=\/etc/--sysconfdir=\/etc\/minicom/g" APKBUILD

RUN adduser -h /home/builder -D builder
RUN addgroup builder abuild
RUN echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

RUN chown builder APKBUILD && cp APKBUILD ~builder
RUN sudo -i -u builder abuild-keygen --append --install -n

RUN sudo -i -u builder abuild checksum
RUN sudo -i -u builder tar xzf ~builder/src/*
RUN mv ~builder/minicom-* ~builder/minicom
RUN sudo -i -u builder mv APKBUILD minicom/

RUN cd ~builder/minicom && sudo -u builder abuild build
RUN cd ~builder/minicom && sudo -u builder abuild -r

RUN apk add ~builder/packages/builder/x86_64/minicom*.apk

ENTRYPOINT ["minicom"]