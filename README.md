# Horizontal Pod Autoscaling (HPA) for the Go test application

This is an example of the k8s deployment of the Go application. When the CPU exceeds a specific threshold, the configuration in this example will be set to automatically scale the number of pods.

- In this example we have limited CPU load to 20%. After that threshold is reached, the number of pods should be increased.
- MIN number of pods has been set to 1
- MAX number of pods has been set to 5


## Setup steps

### (Optional) Prerequisites for local setup w/ <em>podman</em> and <em>minikube</em>

- Install `minikube` and `podman` for local cluster setup
```shell
brew install podman
brew install minikube
```

- Initialize `podman` and assign resources to that virtual machine
```shell
podman machine init --cpus 2 --memory 4096 --rootful
podman machine start
```

- Start minikube
```shell
minikube start --driver podman --extra-config=kubelet.housekeeping-interval=10s
```
> **_NOTE:_**  For easier monitoring use `minikube dashboard`.

- Start metrics-server for resource monitoring
```shell
minikube addons enable metrics-server
```

Reusing Docker daemon (Locally built image)

> **_IMPORTANT:_** If using locally built images, this step is required
> When using a single VM of kubernetes it's really handy to reuse the Docker daemon inside the VM; as this means you don't have to build on your host machine and push the image into a docker registry - you can just build inside the same docker daemon as minikube which speeds up local experiments.
>
> To be able to work with the docker daemon on your mac/linux host use the docker-env command in your shell:

```shell
eval $(minikube -p minikube docker-env)
```

Reference: [Minikube Docs](https://github.com/kubernetes/minikube/blob/0c616a6b42b28a1aab8397f5a9061f8ebbd9f3d9/README.md#reusing-the-docker-daemon)

If you need to delete cluster it is also advisable to remove the minikube configuraiton
  due to leftover configuration in `~/.minikube` which could prevent a successful start on the next run.
```shell
minikube stop
minikube delete
```

To remove/cleanup podman use the following commands:
```shell
podman machine stop podman-machine-default
podman machine rm podman-machine-default
```

## Service setup and deployment

To reduce complexity of running multiple `kubectl` commands, the `Makefile` is used
to simplify setup steps for HPA.

### Docker build

```shell
docker build . -t pavle/go-hpa
docker buildx build --platform=linux/arm64 . -t pavle/go-hpa # For Mac M1 users
```

### Deploy

```shell
make deploy 
# command executing behind scenes:
# kubectl create -f k8s.yml
```

### Enable Autoscaling

```shell
make autoscale 
# command executing behind scenes:
# kubectl autoscale deployment go-hpa --cpu-percent=20 --min=1 --max=5
```

### Show HPA
```shell
make get-hpa 
# command executing behind scenes:
# kubectl get hpa
```

- Example output before load increase:
```shell
NAME     REFERENCE           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
go-hpa   Deployment/go-hpa   0%/20%    1         5         1          15m
```

- Example output after load increase:
```shell
NAME     REFERENCE           TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
go-hpa   Deployment/go-hpa   246%/20%   1         5         4          89s
```

As shown, the number of replicas has been increased due to CPU reaching 20% threshold.

### Simulate load increase

```shell
make increase-load 
# command executing behind scenes:
# kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://go-hpa:8080; done"
```

### Cleanup
```shell
make cleanup 
# commands executing behind scenes:
# kubectl delete -f k8s.yml && \
# kubectl delete pod load-generator && \
# kubectl delete hpa go-hpa
```