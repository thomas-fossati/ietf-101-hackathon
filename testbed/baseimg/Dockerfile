FROM golang:alpine

RUN apk add --no-cache \
      bash \
      bc \
      bridge \
      ca-certificates \
      coreutils \
      drill \
      git \
      iperf3 \
      iproute2 \
      iproute2-doc \
      iputils \
      man \
      tcpdump \
      tshark \
      util-linux

RUN update-ca-certificates

# Manually bugfix traffic control distributions.  They are actually installed
# but not in the location tc expects to find them.
RUN ln -s /usr/lib/tc /lib/tc
