#!/bin/sh
while [ ! -e /lmdb/lmdb ]
do
    echo "Waiting for LMDB to become available"
    sleep 10
done
echo "Starting lightningstream"
lightningstream -c /etc/lightningstream.yaml sync
