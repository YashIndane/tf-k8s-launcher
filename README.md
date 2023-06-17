[![Launching K8s cluster](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml/badge.svg)](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml)

## Usage
```
$ sudo terraform init

$ sudo terraform validate

$ sudo terraform apply -var="worker_node_count=<COUNT>" -auto-approve
```
