#!/bin/bash

helm delete px-mongo --purge
kubectl delete -f px-ha-sc.yaml
kubectl delete -f px-mongo-pvc.yaml
