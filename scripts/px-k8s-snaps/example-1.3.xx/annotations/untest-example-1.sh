#!/bin/bash -ex

kubectl delete -f pod-with-initial-vol.yaml
kubectl delete -f px-demo-vol.yaml
kubectl delete -f px-snap-create.yaml
kubectl delete -f pod-with-restored-vol.yaml
