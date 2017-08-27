#!/bin/bash

echo "Creating secret for mysql..."
tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt password.txt
kubectl create secret generic mysql-pass --from-file=password.txt

echo "Deploying mysql for wordpress..."
kubectl apply -f mysql-vol.yaml
kubectl apply -f mysql.yaml

echo "Deploying wordpress..."
kubectl apply -f wordpress-vol.yaml
kubectl apply -f wordpress.yaml
