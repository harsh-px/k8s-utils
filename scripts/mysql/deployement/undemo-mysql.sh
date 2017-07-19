#!/bin/bash -ex

kubectl delete -f px-mysql.yaml
kubectl delete secret mysql-pass
