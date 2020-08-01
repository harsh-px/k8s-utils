#!/bin/bash -ex

kubectl apply -f px-demo-vol.yaml
kubectl apply -f px-demo-app.yaml

sleep 5

kubectl describe storageclass px-demo-sc
kubectl describe pvc px-demo-pvc
kubectl describe pv
kubectl get pod px-nginx -o wide

