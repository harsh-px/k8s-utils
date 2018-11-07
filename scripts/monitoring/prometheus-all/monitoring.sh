#!/bin/bash -x

kubectl create secret generic alertmanager-portworx --from-file=alertmanager-cfg.yaml -n kube-system
kubectl apply -f .
