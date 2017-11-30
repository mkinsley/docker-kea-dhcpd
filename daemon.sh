# this will run daemonized with name 'my-key-dhcpd'
docker run \
  -it \
  -v ${PWD}/etc/kea:/etc/kea  \
  -v ${PWD}/scripts:/usr/local/scripts \
  --name my-kea-dhcpd \
  -d \
  mwkinsley/kea-dhcpd:latest
