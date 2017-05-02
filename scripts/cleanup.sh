#!/bin/bash

docker stop $(docker ps -a -q --filter ancestor=portworx/px-enterprise:latest)
docker rm $(docker ps -a -q --filter ancestor=portworx/px-enterprise:latest)

docker stop $(docker ps -a -q --filter ancestor=portworx/px-dev:latest)
docker rm $(docker ps -a -q  --filter ancestor=portworx/px-dev:latest)

docker stop $(docker ps -a -q --filter ancestor=harshpx/px:latest)
docker rm $(docker ps -a -q  --filter ancestor=harshpx/px:latest)

docker stop etcd; docker rm etcd
sudo rm -rf /etc/pwx/.private.json /etc/pwx/config.json

#docker rmi harshpx/px
docker system prune -f
