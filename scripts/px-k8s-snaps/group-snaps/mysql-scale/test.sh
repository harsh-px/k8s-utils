#!/bin/bash

start_range=1
end_range=5

setup_groupcloudsnaps-mysql(){

for ((i=$start_range; i<=$end_range; i++))
do
sleep 5
cat <<EOF | kubectl apply -f -
---
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: mysql-groupsnapshot-$i
spec:
  preSnapshotRule: px-mysql-presnap-rule
  postSnapshotRule: px-mysql-postsnap-rule
  pvcSelector:
    matchLabels:
      app: mysql
  options:
    portworx/snapshot-type: cloud
EOF
done
}

setup_groupcloudsnaps-mysql
