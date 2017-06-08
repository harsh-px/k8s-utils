#!/bin/bash


docker run --restart=always --name px -d --net=host \
    --privileged=true                             \
    -v /run/docker/plugins:/run/docker/plugins    \
    -v /var/lib/osd:/var/lib/osd:shared           \
    -v /dev:/dev                                  \
    -v /etc/pwx:/etc/pwx                          \
    -v /opt/pwx/bin:/export_bin                   \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /var/cores:/var/cores                      \
    -v /usr/src:/usr/src                          \
    localhost:5000/harshpx/px:dev -daemon -k etcd://localhost:4001 -c harsh-local-cluster -s /dev/loop0
    #portworx/px-dev:latest
