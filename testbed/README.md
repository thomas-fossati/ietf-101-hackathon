## Base image
```bash
make -C baseimg
```

## Compose targets

- Will build images before starting containers and network:
```bash
make build-up
```

- Start containers and network:
```bash
make up
```

- Stop containers and shutdown network
```bash
make down
```

- Start an interactive shell in the client node (or server, or router):
```bash
make sh-client

Or:
make sh-server
make sh-router
```

## Configuration

The testbed is divided into two domains (1 and 2) connected by the router node.

```
+---------------------+---------------------+
|   --------up------> | --------up------>   |
| C                   R                   S |
|   <------down------ | <------down------   |
+---------------------+---------------------+
        domain 1             domain 2
```

Loss/reordering/latency/rate are applied independently on a per domain and direction basis.

A setup is completely declared by populating the following four variables using [netem](https://wiki.linuxfoundation.org/networking/netem) syntax:

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
bin/link-config.bash
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
