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

RUN go get -u github.com/thomas-fossati/netem-pub/netem \
              github.com/thomas-fossati/netem-pub/netemd \
              github.com/spf13/viper \
              github.com/spf13/cobra

# Compile and install netemd
RUN cd /go/src/github.com/thomas-fossati/netem-pub/netemd && go install

# Manually fix traffic control distributions.  They are actually installed
# but not in the location tc expects to find them.
RUN ln -s /usr/lib/tc /lib/tc


