#!/bin/bash

set -exu

reset_qdiscs() {
  echo ">>> Resetting qdiscs on every interfaces of every container"
  for s in client server router
  do
    for iface in eth0 eth1
    do
      docker-compose exec ${s} tc qdisc del dev ${iface} root || true
    done
  done
}

expect_containers_are_running() {
  echo ">>> Checking containers are running"

  for s in client server router
  do
    x=$(docker-compose ps -q client)
    if [ -z "${x}" ]
    then
      echo ">>> $s MUST be running"
      exit 1
    fi
  done
}

if [ $# != 1 ]
then
  echo "Usage $0 <configuration file>"
  exit 1
fi

readonly CONFIG="$1"

# read links configuration from the supplied file and network configuration
# from .env 
. "${CONFIG}"

. .env

# containers must be up & running for this to work
expect_containers_are_running

# reset qdiscs on all containers
reset_qdiscs

# map link names to the right containers' interfaces
readonly linkmap__DOMAIN1_UPLINK_CONFIG="client eth0"
readonly linkmap__DOMAIN2_DOWNLINK_CONFIG="server eth0"
# TODO(tho) compute the following two dynamically from .env and current
# container instantiation
readonly linkmap__DOMAIN1_DOWNLINK_CONFIG="router eth0"
readonly linkmap__DOMAIN2_UPLINK_CONFIG="router eth1"

# apply configuration
for k in "DOMAIN1_UPLINK_CONFIG" "DOMAIN1_DOWNLINK_CONFIG" \
         "DOMAIN2_UPLINK_CONFIG" "DOMAIN2_DOWNLINK_CONFIG"
do
  if [ ! -z "${!k}" ]
  then
    n=linkmap__${k}
    # ( vars[0] vars[1] ) <=> ( container-name network-interface )
    vars=( ${!n} )
    cmd="tc qdisc add dev ${vars[1]} root netem ${!k}"
    docker-compose exec ${vars[0]} ${cmd}
  else
    echo ">>> Skipping empty $k"
  fi
done

exit 0

# vim: ai ts=2 sw=2 et sts=2 ft=sh
