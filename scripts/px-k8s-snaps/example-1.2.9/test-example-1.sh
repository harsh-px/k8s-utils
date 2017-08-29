#!/bin/bash -e

echo "Creating initial volume and application for snaps..."
kubectl apply -f px-demo-vol.yaml
kubectl apply -f pod-with-initial-vol.yaml

echo "TODO: writing some data for the initial volume"

echo "Creating snapshot of the volume..."
kubectl apply -f px-snap-create.yaml

echo "TODO: writing more data for the initial volume"

echo "Restoring pod from previous snapshot..."
kubectl apply -f pod-with-restored-vol.yaml
