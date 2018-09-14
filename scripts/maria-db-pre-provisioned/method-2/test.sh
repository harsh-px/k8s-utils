#!/bin/bash

PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume create mariadb-data-vol --size=5 

kubectl apply -f statefulset.yaml
