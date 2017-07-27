#!/bin/bash -ex

kubectl delete -f px-nginx-app-with-pod-affinity.yaml
kubectl delete -f px-nginx-vol.yaml
