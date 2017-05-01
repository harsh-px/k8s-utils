#!/bin/bash

docker run --restart=always --name etcd -v /data/varlib/etcd -p 4001:4001 -d portworx/etcd:latest

#docker run --restart=always --name px-dev -d --net=host \
#    --privileged=true                             \
#    -v /run/docker/plugins:/run/docker/plugins    \
#    -v /var/lib/osd:/var/lib/osd:shared           \
#    -v /dev:/dev                                  \
#    -v /etc/pwx:/etc/pwx                          \
#    -v /opt/pwx/bin:/export_bin                   \
#    -v /var/run/docker.sock:/var/run/docker.sock  \
#    -v /var/cores:/var/cores                      \
#    -v /var/lib/kubelet:/var/lib/kubelet:shared   \
#    -v /usr/src:/usr/src                          \
#    harshpx/px:latest -daemon -k etcd://192.168.33.10:4001 -c harsh-k8s-cluster -x kubernetes -m enp0s8 -d enp0s8 
#    #portworx/px-dev:latest
