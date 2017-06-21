#!/bin/bash -ex

echo mysql123 > password.txt
tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt password.txt
kubectl create secret generic mysql-pass --from-file=password.txt
kubectl apply -f px-mysql.yaml

sleep 5

kubectl describe -f px-mysql.yaml
