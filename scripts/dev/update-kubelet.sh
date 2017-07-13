#!/bin/bash -ex

echo "Stopping kubelet service..."
service kubelet stop

echo "Updating kubelet..."
echo "md5 before: `md5sum /usr/bin/kubelet`"
cp /vagrant/kubelet /usr/bin/kubelet
echo "md5 after: `md5sum /usr/bin/kubelet`"

echo "Restarting kubelet service..."
service kubelet start