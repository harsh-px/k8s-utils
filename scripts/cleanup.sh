#!/bin/bash

IMAGES_TO_CLEAN=(
    "portworx/etcd:latest"
    "portworx/px-dev:latest"
	"harshpx/px:dev"
	"192.168.33.1:5000/harshpx/px:dev"
	"portworx/px-enterprise:latest"
)

for IMG in "${IMAGES_TO_CLEAN[@]}"
do
	docker stop $(docker ps -a -q --filter ancestor=${IMG}) 2>/dev/null
	docker rm -f $(docker ps -a -q --filter ancestor=${IMG}) 2>/dev/null
done

sudo rm -rf /etc/pwx
docker system prune -f 2>/dev/null
