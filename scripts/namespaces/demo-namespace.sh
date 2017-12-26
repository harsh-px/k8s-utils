#!/bin/bash

echo "Creating namespaces and contexts..."
kubectl create -f dev-namespace.yaml
kubectl create -f prod-namespace.yaml
kubectl config set-context dev --namespace=dev --cluster=kubernetes --user=kubernetes-admin
kubectl config set-context prod --namespace=prod --cluster=kubernetes --user=kubernetes-admin

echo "Switching to prod context..."
kubectl config use-context prod

kubectl create --namespace prod -f ../px-basic-demo/px-demo-all.yaml

sleep 5

kubectl describe --namespace prod -f ../px-basic-demo/px-demo-all.yaml

echo "Switching to dev context..."
kubectl config use-context dev
kubectl describe pvc
kubectl describe pv
