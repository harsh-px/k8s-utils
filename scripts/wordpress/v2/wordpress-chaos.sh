#!/bin/bash -e

EXPECTED_RUNNING=3

c=0
while [ 1 ]; do
  # Randomly delete a portworx pod
  pod_to_del=`kubectl get pods -l name=portworx -n kube-system | grep Running | awk '{print $1}' |  shuf | head -n 1`
  echo "[loop: $((c++)) `date` ] Deleting portworx pod: ${pod_to_del}"
  kubectl delete pod ${pod_to_del} -n kube-system

  fail=false
  # Check crash loop backoff pods
  for crashed in `kubectl get pods -l name=wordpress | grep Crash | awk '{print $1}'`; do
     echo "Pod ${crashed} is in crash loop backoff state..."
     fail=true
  done

  # Match current running and expected running
  running_count=`kubectl get pods -l name=wordpress | grep Running | awk '{print $1}' | wc -l`
  if [ $running_count -ne $EXPECTED_RUNNING ]; then
    echo "Total running wordpress pods: ${running_count} don't match expected running: ${EXPECTED_RUNNING}"
    kubectl get pods -l name=wordpress
    fail=true
  fi

  if [ "$fail" = true ]; then
    echo "Exiting script as fail flag is set..."
    exit -1
  fi

  # Delete all wordpress pods
  for w in `kubectl get pods -l name=wordpress | grep Running | awk '{print $1}'`; do
    echo "[`date`] Deleting wordpress pod: ${w}"
    kubectl delete pod $w
  done

  sleep 120

  # Read the test.txt to ensure it's present
  for w in `kubectl get pods -l name=wordpress | grep Running | awk '{print $1}'`; do
    kubectl exec $w -c wordpress -- cat /var/www/html/test.txt
  done

done
