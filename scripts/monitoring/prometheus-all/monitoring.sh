#!/bin/bash -ex 

kubectl create secret generic alertmanager-portworx --from-file=alertmanager-cfg.yaml -n kube-system
kubectl apply -f .
