#!/bin/bash

for i in {1..3}; do
	kubectl create ns pg$i || true
  kubectl apply -f pgbench-pvc.yaml -n pg$i
done

# list volumes
pxctl v l

# status
pxctl cluster provision-status --output-type wide

# rebalance submit
#pxctl service pool rebalance submit --thresholds 'metric=provision_space,over=75,under=10,type=absolute_percent'

# status
while true; do
	pxctl cluster provision-status --output-type wide
	sleep 2
done
