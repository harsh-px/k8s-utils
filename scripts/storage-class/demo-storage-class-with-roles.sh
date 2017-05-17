#!/bin/bash -ex

kubectl create -f px-sc-all.yaml

sleep 5

kubectl describe storageclass portworx-io-priority-high
kubectl describe pvc
kubectl describe pv
kubectl get pod pvpod

