This is a small utility container to create a custom kubeconfig file using a given Kubernetes service account.

## Building

```
export DOCKER_IMAGE=<GIVE-YOUR-IMAGE-NAME>
docker build -t $DOCKER_IMAGE
docker push $DOCKER_IMAGE
```

## Running as docker container

Below is an example on how to run the container you build above.

* `/etc/kubernetes/admin.conf` is the kubeconfig file on the host machine that will be used by the container
* `/etc/pwx` is where the container will create the kubeconfig file for the given service account. The file will be at `/etc/pwx/px-kubeconfig`.

```
export DOCKER_IMAGE=<GIVE-YOUR-IMAGE-NAME>
docker run -e KUBECONFIG=/etc/kubernetes/admin.conf \
           -v /etc/kubernetes/admin.conf:/etc/kubernetes/admin.conf \
           -v /etc/pwx:/etc/pwx $DOCKER_IMAGE px-account kube-system
```
