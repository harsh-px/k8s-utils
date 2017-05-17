#!/bin/bash

kubectl create -f dev-namespace.yaml
kubectl create -f prod-namespace.yaml
kubectl config set-context dev --namespace=dev --cluster=kubernetes --user=kubernetes-admin
kubectl config set-context prod --namespace=prod --cluster=kubernetes --user=kubernetes-admin

