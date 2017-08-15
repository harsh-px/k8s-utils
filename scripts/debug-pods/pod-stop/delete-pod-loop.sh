#!/bin/bash -x

while [ 1 ]; do sleep 10 ; kubectl get pods | grep nginx | awk '{print $1}' | xargs kubectl delete pod; done

