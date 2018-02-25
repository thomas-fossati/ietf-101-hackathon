## Base image
First thing to do is creating the base Docker image that is used for all the nodes in the testbed:
```bash
make -C baseimg
```

## Compose targets
The testbed is started with one of `build-up` or `up`.

- Use `build-up` when you need to build nodes' images before starting containers and network (for example, the very first time or after you change the nodes' images in some way - e.g., when modifying the entrypoint script):
```bash
make build-up
```

- Use `up` in all other cases:
```bash
make up
```

To start an interactive shell in the `client` (or `server`, or `router`) node:
```bash
make sh-client

Or:
make sh-server
make sh-router
```

(On MacOSX, if using iTerm2, `make iterms` creates a window with a tile and an interactive shell for each testbed node.)


To stop the containers and shutdown the compose network:
```bash
make down
```

## Configuration

The testbed is divided into two domains ('client' and 'server') connected by the router node.

```
+---------------------+---------------------+
|   --------up------> | --------up------>   |
| C                   R                   S |
|   <------down------ | <------down------   |
+---------------------+---------------------+
      client domain       server domain
```

Loss/reordering/latency/rate are applied independently on a per domain and direction basis.

Thus, a test setup is completely declared by populating the following four variables using [netem](https://wiki.linuxfoundation.org/networking/netem) syntax:

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

In order to apply this configuration to a new compose instance, run:
```bash
bin/link-config.bash conf/ex1.conf
```

A quick test to check that the expected configuration is in place:
```bash
# downlink
docker-compose exec server ping client

# uplink
docker-compose exec client ping server
```

If anything goes wrong half-way through, reset the qdisc configuration to its default:
```bash
bin/link-reset.bash
```

# Configuration

To create a picture of a given configuration (for example [ex2.conf](conf/ex2.conf)) - including per-link characteristics and addressing of all the involved nodes - use the following command:
```bash
bin/dot-conf.bash conf/ex2.conf
```

Something like the following should show up:

![Alt text](pics/ex2.conf.png?raw=true "configuration pic")


# Dashboards

Navigate to [http://localhost:8888/sources/0/dashboards/1](http://localhost:8888/sources/0/dashboards/1).  What should pop up is something like the following:

![Alt text](pics/dashboards.png?raw=true "dashboards pic")

