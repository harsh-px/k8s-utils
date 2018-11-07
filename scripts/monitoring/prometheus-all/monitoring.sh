#!/bin/bash -x

kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system
kubectl apply -f .
