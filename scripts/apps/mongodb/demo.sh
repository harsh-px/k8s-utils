#!/bin/bash

kubectl apply -f px-ha-sc.yaml
kubectl apply -f px-mongo-pvc.yaml
helm install --name px-mongo \
    --set usePassword=false,persistence.existingClaim=px-mongo-pvc \
    stable/mongodb
kubectl get pods -o wide
