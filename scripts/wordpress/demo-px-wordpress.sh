#!/bin/bash -ex

tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt password.txt
kubectl create secret generic mysql-pass --from-file=password.txt
kubectl apply -f px-mysql.yaml
kubectl apply -f px-qp-app.yaml
