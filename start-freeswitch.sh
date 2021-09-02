#!/bin/bash

n=0
while [ "$n" -lt 10 ] && [ -z "`netstat -tln | grep 5432`" ]; do
    n=$(( n + 1 ))
    sleep 1
done

if [ "$n" -eq 10 ]; then
    exit 1
fi

# Start server.
echo 'Starting Freeswitch...'
/usr/bin/freeswitch -u www-data -g www-data  -rp -nonat
