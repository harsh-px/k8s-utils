#!/bin/sh -x

function sighandler() {
    echo "sighandler"
    sleep 5
    echo "making directory foo..."
    mkdir -p /var/sighandler/foo
    sleep 100
}

trap sighandler SIGINT SIGTERM

echo "making directory foo2..."
mkdir -p /var/sighandler/foo2

while [ 1 ] ; do sleep 1000; done