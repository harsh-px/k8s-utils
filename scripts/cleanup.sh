#!/bin/bash

IMAGES_TO_CLEAN=(
	"portworx/px-dev:latesat"
	"harshpx/px:latest"
	"192.168.33.1:5000/harshpx/px:latest"
	"portworx/px-enterprise:latest"
)

for IMG in "${IMAGES_TO_CLEAN[@]}"
do
	docker stop $(docker ps -a -q --filter ancestor=${IMG}) 2>/dev/null
	docker rm $(docker ps -a -q --filter ancestor=${IMG}) 2>/dev/null
done

sudo rm -rf /etc/pwx
docker system prune -f 2>/dev/null
