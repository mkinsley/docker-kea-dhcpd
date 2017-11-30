#!/bin/bash

# run a container

docker run \
  -it \
  -v ${PWD}/etc/kea:/etc/kea  \
  -v ${PWD}/scripts:/usr/local/scripts \
  --rm \
  mwkinsley/kea-dhcpd:latest $@
