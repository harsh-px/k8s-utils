#!/bin/bash

docker stop px-dev; docker rm px-dev
docker stop etcd; docker rm etcd
sudo rm -rf /etc/pwx/.private.json /etc/pwx/config.json

#docker rmi harshpx/px
docker system prune -f
