# syntax=docker/dockerfile:1

# Building minicom from downloaded APKBUILD

FROM alpine:latest AS build

# Install build dependencies
RUN apk add --no-cache abuild linux-headers build-base sudo curl ncurses-dev gettext-dev

# Download APKBUILD from Alpine gitlab
RUN wget https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/minicom/APKBUILD

# Modify APKBUILD to use /etc/minicom as sysconfdir
RUN sed -i "s/--sysconfdir=\/etc/--sysconfdir=\/etc\/minicom/g" APKBUILD

# Create non-root user for running build tools and assign to relevent groups
RUN adduser -h /home/builder -D builder
RUN addgroup builder abuild
RUN echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder

# Set ownership of APKBUILD and copy to non-root homedir
RUN chown builder APKBUILD && cp APKBUILD ~builder

# Generate and install keys for non-root user
RUN sudo -i -u builder abuild-keygen --append --install -n

# Running as non-root user, create build environment from APKBUILD
RUN sudo -i -u builder abuild checksum
# Fetch source
RUN sudo -i -u builder tar xzf ~builder/src/*
# Rename folder for convenience
RUN mv ~builder/minicom-* ~builder/minicom
# Move APKBUILD to source directory
RUN sudo -i -u builder mv APKBUILD minicom/

# Change to source directory and compile
RUN cd ~builder/minicom && sudo -u builder abuild build
# Change to source directory and generate packages
RUN cd ~builder/minicom && sudo -u builder abuild -r
# Install generated packages into build environment
RUN apk add ~builder/packages/builder/x86_64/minicom*.apk

# New container from fresh Alpine base image
FROM alpine:latest

# Install official minicom package
RUN apk add --no-cache minicom

# Copy minicom binary generated from build environment and overwrite official one
COPY --from=build /usr/bin/minicom /usr/bin/minicom

# Entrypoint is minicom binary with optional color argument. Set to off or delete if desired.
ENTRYPOINT ["minicom", "--color=on"]

# With newly generated minicom binary, connection profiles now properly get saved to /etc/minicom. Map volume to this location for access to profiles.
# After building with tag name (such as 'minicom-docker'), run with 'sudo docker run --privleged -it --rm --name=minicom -v /path/to/profiles:/etc/minicom minicom-docker argument'
# Where argument is the saved name of a previously configured minicom connection profile or '-s' to configure a new connection profile. Example: 'sudo docker run --privleged -it --rm --name=minicom -v /path/to/profiles:/etc/minicom minicom-docker -s'
# Alternatively, instead of --privileged, you can pass the specific tty device, such as --device=/dev/ttyS0 or --device=/dev/ttyUSB0.