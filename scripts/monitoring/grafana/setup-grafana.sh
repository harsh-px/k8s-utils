#!/bin/bash 

kubectl apply -f secret-grafana-credentials.yaml
kubectl apply -f configmap-grafana-dashboards.yaml
kubectl apply -f deployment-grafana.yaml
kubectl apply -f service-grafana.yaml
