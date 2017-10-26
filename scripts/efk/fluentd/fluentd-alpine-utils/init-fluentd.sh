#!/bin/sh

PX_SERVICE="portworx-service.kube-system.svc.cluster.local"
if [ -n "$1" ]; then
    PX_SERVICE="$1"
fi

echo "Using service: $PX_SERVICE"

pxClusterStatus=$(curl -XGET http://$PX_SERVICE:9001/v1/cluster/enumerate)

while [[ "$pxClusterStatus" = "" ]]
do
 echo "Waiting... looks like the px pods arent ready yet"
 sleep 1
 pxClusterStatus=$(curl -XGET http://$PX_SERVICE:9001/v1/cluster/enumerate)
done

echo $pxClusterStatus
echo $pxClusterStatus >> /usr/bin/clusterState

indexID=$(echo $pxClusterStatus | jq -r '.["Id"]+"-"+.["UID"]')

echo "Using index ID: $indexID"

cat /tmp/fluent.conf

sed -i "s/#indexUUID#/$indexID/g" /tmp/fluent.conf
