#!/bin/bash -ex

kubectl delete -f px-mysql-app.yaml
kubectl delete -f px-mysql-vol.yaml
kubectl delete secret mysql-pass
