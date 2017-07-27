#!/bin/bash -ex

kubectl apply -f px-nginx-vol.yaml
kubectl apply -f px-nginx-app-with-pod-affinity.yaml

sleep 5

kubectl describe -f px-nginx-vol.yaml
kubectl describe -f px-nginx-app-with-pod-affinity.yaml

