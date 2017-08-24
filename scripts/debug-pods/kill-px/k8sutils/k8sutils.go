package k8sutils

import (
	k8s "k8s.io/client-go/1.5/kubernetes"
	k8s_rest "k8s.io/client-go/1.5/rest"

	"fmt"
)

// GetK8sClient instantiates a k8s client and tests if it can list nodes
func GetK8sClient() (*k8s.Clientset, error) {
	k8sClient, err := loadClientFromServiceAccount()
	if err != nil {
		return nil, err
	}

	if k8sClient == nil {
		return nil, fmt.Errorf("Unable to get a k8s client.")
	}

	_, err = k8sClient.Core().Nodes().List(k8s_api.ListOptions{})
	if err != nil {
		return nil, err
	}

	return k8sClient, nil
}

// loadClientFromServiceAccount loads a k8s client from a ServiceAccount specified in the pod running px
func loadClientFromServiceAccount() (*k8s.Clientset, error) {
	config, err := k8s_rest.InClusterConfig()
	if err != nil {
		return nil, err
	}

	k8sClient, err := k8s.NewForConfig(config)
	if err != nil {
		return nil, err
	}
	return k8sClient, nil
}
