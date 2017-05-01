#!/bin/bash -ex

for SERVICE in kube-proxy kubelet flanneld docker; do 
	systemctl status $SERVICE
	journalctl -r -u $SERVICE
done
