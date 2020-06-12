#!/bin/bash

NUM_NS=3

for i in {1..3}; do
  kubectl delete -f pgbench-pvc.yaml -n pg$i
done
