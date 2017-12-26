Building the test image
```bash
docker build -t harshpx/pod-stop .
docker push harshpx/pod-stop
```

Start the pod deployment
```bash
kubectl apply -f pod-stop-test.yaml
```

Start pod deletion in a loop.
```bash
screen -dmSL delete-pod `pwd`/delete-pod-loop.sh
```