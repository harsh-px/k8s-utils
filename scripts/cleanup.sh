#!/bin/bash

docker stop $(docker ps -a -q --filter ancestor=portworx/px-enterprise:latest)
docker rm $(docker ps -a -q --filter ancestor=portworx/px-enterprise:latest)

docker stop $(docker ps -a -q --filter ancestor=portworx/px-dev:latest)
docker rm $(docker ps -a -q  --filter ancestor=portworx/px-dev:latest)

docker stop $(docker ps -a -q --filter ancestor=harshpx/px:latest)
docker rm $(docker ps -a -q  --filter ancestor=harshpx/px:latest)

docker stop $(docker ps -a -q --filter ancestor=portworx/etcd:latest)
docker rm $(docker ps -a -q  --filter ancestor=portworx/etcd:latest)

sudo rm -rf /etc/pwx
docker system prune -f
