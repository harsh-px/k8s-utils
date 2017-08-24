This test deploys a pod that randomly deletes a PX pod deployed via the DaemonSet

### Compile
make

### Deploy
make deploy

### Run
kubectl apply -f px-killer.yaml