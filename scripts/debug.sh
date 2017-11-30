#!/bin/sh

#LOGFILE=/tmp/kea-hook-runscript-debug.log

# on docker our pid 1 STDOUT will be the log...
# this should output along with the regular kea console logs
LOGFILE=/proc/1/fd/1
echo "== $1 ==" >> $LOGFILE
date >> $LOGFILE
env >> $LOGFILE
echo >> $LOGFILE
echo >> $LOGFILE
