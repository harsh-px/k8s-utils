#!/bin/sh -x

function sighandler() {
    echo "sighandler"
    sleep 5
    echo "making directory foo..."
    mkdir -p /var/sighandler/foo
    sleep 100
}

trap sighandler SIGINT SIGTERM

echo "Pod stop application with hostname: ${HOSTNAME} starting..."

sleep 2
echo "making directory foo2..."
mkdir -p /var/sighandler/foo2
echo `date` >> /var/sighandler/foo2/times