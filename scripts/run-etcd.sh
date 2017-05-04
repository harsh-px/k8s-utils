#!/bin/bash

docker run --restart=always --name etcd -v /data/varlib/etcd -p 4001:4001 -d portworx/etcd:latest
