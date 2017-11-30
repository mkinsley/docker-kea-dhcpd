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
