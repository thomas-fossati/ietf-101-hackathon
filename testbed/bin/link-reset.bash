#!/bin/bash

set -eu

echo ">>> Resetting qdiscs on every interface of every container"

for s in client server router
do
  for iface in eth0 eth1
  do
    docker-compose exec ${s} tc qdisc del dev ${iface} root 2>&1 > /dev/null || true
  done
done
