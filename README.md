# docker-kea-dhcpd

the run.sh helper will do the ugly business of invoking docker and mapping
config files.

the etc/kea and scripts/ directories are mounted into the container.


```
# this will give you a bash prompt into the container
./run.sh /bin/bash
```

```
# without any args it will run the dhcp server in the foreground
# debug level logging
# by default the debug.sh hook will print to STDOUT of the container
./run.sh
```


```
# run daemonized
./daemon.sh
```

now you should have a running dhcp server

```
# you should see your container runnning
docker ps
```

it should be listening on udp 67
```
nc  -uvz localhost 67
```

when you want to stop the container

```
docker stop my-kea-dhcpd
```

To see logs (process STDOUT)

```
docker logs my-kea-dhcpd
````

To remove the container and any volumes

```
docker rm -fv my-kea-dhcpd
```
# Docker Compose

```
# stack.sh just calls out to docker-compose
./stack.sh
```
## start compose stack
```
docker-compose up -d
```
## connect to container in stack
```
docker-compose exec minion /bin/bash
```
## get logs from container in stack
```
docker-compose logs dhcpd
```
## stop stack
```
docker-compose stop
```

## teardown stack
```
docker-compose down -v
```
