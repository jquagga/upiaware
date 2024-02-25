FROM debian:12-slim@sha256:d02c76d82364cedca16ba3ed6f9102406fa9fa8833076a609cabf14270f43dfc AS builder
WORKDIR /app/git
ARG TARGETPLATFORM
RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential git devscripts debhelper tcl8.6-dev autoconf \
    python3-dev python3-venv python3-setuptools libz-dev openssl \
    libboost-system-dev libboost-program-options-dev libboost-regex-dev python3-wheel python3-pip python3-build \
    libboost-filesystem-dev patchelf wget ca-certificates && \
    git clone --depth 1 https://github.com/flightaware/piaware_builder /app/git && \
    bash sensible-build.sh bookworm
WORKDIR /app/git/package-bookworm
RUN dpkg-buildpackage -b --no-sign && rm ../piaware-dbgsym*
WORKDIR /copydeb
RUN cp /app/git/*.deb /copydeb 

FROM debian:12-slim@sha256:d02c76d82364cedca16ba3ed6f9102406fa9fa8833076a609cabf14270f43dfc
WORKDIR /copydeb
COPY --from=builder /copydeb /copydeb
RUN apt-get update && apt-get install --no-install-recommends -y /copydeb/*.deb && rm /copydeb/*
USER 65532

ENTRYPOINT ["/usr/bin/piaware"]