# TODO(tho) factor out
FROM alpine_3.7-transport-measurability:latest

# Get netemd source and dependencies
RUN go get -u github.com/thomas-fossati/netem-pub/netem \
              github.com/thomas-fossati/netem-pub/netemd \
              github.com/spf13/viper \
              github.com/spf13/cobra

# Compile and install netemd
RUN cd /go/src/github.com/thomas-fossati/netem-pub/netemd && go install

# netemd is launched in the entrypoint script after network interfaces are
# configuration as needed
COPY entrypoint.bash /root/

# The entrypoint for this container is defined in docker-compose.yml
