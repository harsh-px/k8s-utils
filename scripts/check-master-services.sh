#!/bin/bash -ex

for SERVICE in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
	systemctl status $SERVICE 
	journalctl -r -u $SERVICE                                                  
done   
