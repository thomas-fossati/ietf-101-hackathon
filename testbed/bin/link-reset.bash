#!/bin/bash

set -exu

echo ">>> Resetting qdiscs on every interfaces of every container"

for s in client server router
do
  for iface in eth0 eth1
  do
    docker-compose exec ${s} tc qdisc del dev ${iface} root || true
  done
done
