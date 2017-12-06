#!/bin/bash 

kubectl delete -f service-grafana.yaml
kubectl delete -f deployment-grafana.yaml
kubectl delete -f configmap-px-grafana-dashboards.yaml
kubectl delete -f secret-grafana-credentials.yaml
