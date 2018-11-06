#!/bin/bash -ex 

kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system
kubectl apply -f .
