package main

import (
	"github.com/Sirupsen/logrus"
	"github.com/harsh-px/k8s-utils/scripts/debug-pods/kill-px/k8sutils"
)

func main() {
	logrus.Infof("Starting...")


	client, err := k8sutils.GetK8sClient()
	if err != nil {
		logrus.Errorf("Failed to get k8s client. Err: %v", err)
		return
	}


}