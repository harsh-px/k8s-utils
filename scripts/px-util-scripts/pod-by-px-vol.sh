#!/bin/bash

# Credits: Aditya Dani (aditya@portworx.com)

portworx_pod_name=`kubectl get pods -n kube-system |grep portworx | awk '{ if (NR==1) print $1 }'`
pv_name=$1

function get_pvc_details() {
        i=$1
        echo "---------";
        echo "PV Name: $i"
        ns=`kubectl get pvc --all-namespaces | grep $i | awk -F' ' '{print $1}'`;
        claim_name=`kubectl get pvc --all-namespaces | grep $i | awk -F' ' '{print $2}'`;
        echo "PVC Namespace: $ns"
        echo "PVC Name: $claim_name"

        for j in $(kubectl get pods -n $ns | grep -v NAME | awk -F' ' '{print $1}');
        do
            grep_output=`kubectl describe pods $j -n $ns | grep $claim_name`
            if [ "$grep_output" != "" ]; then
                echo "POD Name: $j";
            fi
        state=`kubectl exec -it $portworx_pod_name -n kube-system /opt/pwx/bin/pxctl v i $i |grep Attached | grep Attached | awk -F' ' '{print $4}'`
        echo "Volume attached on: $state"
        replicas=`kubectl exec -it $portworx_pod_name -n kube-system /opt/pwx/bin/pxctl v i $i |grep Node | grep Node | awk -F' ' '{print $3}'`
        echo "Replica set: $replicas"
        done
}

if [ "$pv_name" == "" ]; then
    # loop over all pvcs
    for i in $(kubectl exec -it $portworx_pod_name -n kube-system /opt/pwx/bin/pxctl v l | grep -v NAME | grep attached | awk -F' ' '{print $2}');
    do
        get_pvc_details $i
    done
else
    pv_name=`kubectl exec -it $portworx_pod_name -n kube-system /opt/pwx/bin/pxctl v l | grep $pv_name | awk -F' ' '{print $2}'`
    get_pvc_details $pv_name
fi