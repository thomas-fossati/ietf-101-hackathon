# What is this about?

This package is meant to provide a testbed for measuring the effects of varying network conditions on transport protocols.

The testbed consists of two networks connected by a router node and a third (separate) network hosting the measurements store and analysis / visualisation harness.

The testbed is based on [Docker Compose](docker-compose.yml) and looks a bit like this:

![Alt text](pics/docker-compose.png?raw=true "docker compose network")

If you are confused by the above pic, the following provides a simplified view that only takes the test networks into consideration:

![Alt text](pics/ex0.conf.png?raw=true "simple pic")

The most important thing to note here is that network characterisation (loss, reordering, duplication and latencies) can be specified independently for each domain and direction.

# Setup

Before proceeding, make sure the required dependencies are installed.  See the top level [README.md](../README.md) for the details.

## Get the software
```
$ git clone https://github.com/thomas-fossati/ietf-101-hackathon.git
```

## Enter the testbed
```
$ cd ietf-101-hackathon/testbed
```

## Build the base Docker image
This step creates the base Docker image shared by all test nodes - client, router and server:
```
$ make -C baseimg
```

## Start the Docker Compose network
The following command starts the whole testbed, including the store and dashboarding components:
```
$ make up
```

## Push the pre-canned dashboards to Chronograf
```
$ make dash
```
Look for a 201 Created status code from the Chronograf server.  This is the signal that the dashboards have been installed and can now be viewed at [http://localhost:8888/sources/0/dashboards/1](http://localhost:8888/sources/0/dashboards/1).  What should pop up is something like the following:

![Alt text](pics/dashboards.png?raw=true "pre-canned dashboards")

The dashboard on top shows the end-to-end latency breakdown.  Each line represents a one-way delay measure (client->router, router->client, router->server, server->router) in milliseconds.

Each network segment has its own dashboard for PPS, reordering and loss per direction.

# Configuration

A test setup is completely declared by populating the following four variables using [netem](https://wiki.linuxfoundation.org/networking/netem) syntax:

- `CLIENT_DOMAIN_UPLINK_CONFIG`
- `CLIENT_DOMAIN_DOWNLINK_CONFIG`
- `SERVER_DOMAIN_UPLINK_CONFIG`
- `SERVER_DOMAIN_DOWNLINK_CONFIG`

If a key is empty, the configuration for the corresponding link/direction is skipped.

Example (see also `config/ex1.conf`):
```
# add latency in uplink on domain 1 using uniform distribution in range
# [90ms-110ms]
CLIENT_DOMAIN_UPLINK_CONFIG="delay 100ms 10ms"

# downlink in domain 1 is the perfect channel
CLIENT_DOMAIN_DOWNLINK_CONFIG=

# add random packet drop in uplink on domain 2 with probability 0.3% and 25%
# correlation with drop decision for previous packet
SERVER_DOMAIN_UPLINK_CONFIG="loss 0.3% 25%"

# add random packet drop in downlink on domain 2 with probability 0.1%
SERVER_DOMAIN_DOWNLINK_CONFIG="loss 0.1%"
```

In order to apply this configuration to a running testbed instance, run:
```
$ bin/link-config.bash conf/ex1.conf
```

A quick test to check that the expected configuration is in place:
```
# downlink
$ docker-compose exec server ping client
```

To create a picture of a given configuration (for example [ex2.conf](conf/ex2.conf)) - including per-link characteristics and addressing of all the involved nodes - use the following command:
```
$ bin/dot-conf.bash conf/ex2.conf
```

Something like the following should show up:

![Alt text](pics/ex2.conf.png?raw=true "configuration pic")
