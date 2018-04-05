#!/bin/bash

# Credits to Aditya Dani (aditya@portworx.com) for writing the original version of this script

portworx_pod_name=`kubectl get pods -n kube-system |grep portworx | awk '{ if (NR==1) print $1 }'`
node_name=$1
if [ -z "$node_name" ]; then
  echo "node name is required"
  exit
fi

operation=$2
if [ -z "$operation" ]; then
  echo "operation is required. It should be either list or delete"
  exit
fi

echo "user requested $operation on PX pods on node: $node_name"

function px_pods_by_node_name() {
    i=$1
    ns=`kubectl get pvc --all-namespaces | grep $i | awk -F' ' '{print $1}'`;
    claim_name=`kubectl get pvc --all-namespaces | grep $i | awk -F' ' '{print $2}'`;

    for j in $(kubectl get pods -n $ns -o wide | grep -v NAME | grep $node_name | awk -F' ' '{print $1}');
    do
        grep_output=`kubectl describe pods $j -n $ns | grep $claim_name`
        if [ "$grep_output" != "" ]; then
            if [ "$operation" == "delete" ]; then
                echo "Deleting pod: $j in $ns namespace";
                kubectl delete pod $j -n $ns
            elif [ "$operation" == "list" ]; then
                kubectl get pod $j -n $ns | grep -v NAME
            else
                echo "invalid operation: $operation"
                exit 1
            fi
        fi
    done
}

# loop over all pvs
for i in $(kubectl exec -it $portworx_pod_name -n kube-system /opt/pwx/bin/pxctl v l | grep -v NAME | grep attached | awk -F' ' '{print $2}');
do
    px_pods_by_node_name $i
done
