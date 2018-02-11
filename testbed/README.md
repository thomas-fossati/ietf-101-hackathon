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

(On MacOSX, if using iTerm2, invoking `make iterms` creates a window with a tile with an interactive shell for each testbed node.)


To stop the containers and shutdown the compose network:
```bash
make down
```

## Configuration

The testbed is divided into two domains ('1' and '2') connected by the router node.

```
+---------------------+---------------------+
|   --------up------> | --------up------>   |
| C                   R                   S |
|   <------down------ | <------down------   |
+---------------------+---------------------+
        domain 1             domain 2
```

Loss/reordering/latency/rate are applied independently on a per domain and direction basis.

Thus, a test setup is completely declared by populating the following four variables using [netem](https://wiki.linuxfoundation.org/networking/netem) syntax:

- `DOMAIN1_UPLINK_CONFIG`
- `DOMAIN1_DOWNLINK_CONFIG`
- `DOMAIN2_UPLINK_CONFIG`
- `DOMAIN2_DOWNLINK_CONFIG`

If a key is empty, the configuration for the corresponding link/direction is skipped.

Example (see also `config/ex1.conf`):
```
# add latency in uplink on domain 1 using uniform distribution in range
# [90ms-110ms]
DOMAIN1_UPLINK_CONFIG="delay 100ms 10ms"

# downlink in domain 1 is the perfect channel
DOMAIN1_DOWNLINK_CONFIG=

# add random packet drop in uplink on domain 2 with probability 0.3% and 25%
# correlation with drop decision for previous packet
DOMAIN2_UPLINK_CONFIG="loss 0.3% 25%"

# add random packet drop in downlink on domain 2 with probability 0.1%
DOMAIN2_DOWNLINK_CONFIG="loss 0.1%"
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
```
bin/link-reset.bash
```
