#!/bin/bash


docker run --restart=always --name px-dev -d --net=host \
    --privileged=true                             \
    -v /run/docker/plugins:/run/docker/plugins    \
    -v /var/lib/osd:/var/lib/osd:shared           \
    -v /dev:/dev                                  \
    -v /etc/pwx:/etc/pwx                          \
    -v /opt/pwx/bin:/export_bin                   \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /var/cores:/var/cores                      \
    -v /usr/src:/usr/src                          \
    harshpx/px:latest -daemon -k etcd://localhost:4001 -c harsh-k8s-cluster -a -f
    #portworx/px-dev:latest
