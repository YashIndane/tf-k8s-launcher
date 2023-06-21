# tf-k8s-launcher

[![Launching K8s cluster](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml/badge.svg)](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml) ![](https://img.shields.io/badge/Ansible-black?logo=ansible&logoColor=white) ![](https://img.shields.io/badge/AWS-yellow?logo=amazon&logoColor=white) ![](https://img.shields.io/badge/Terraform-purple?logo=terraform&logoColor=white) ![](https://img.shields.io/badge/Kubernetes-blue?logo=kubernetes&logoColor=white) ![](https://img.shields.io/badge/License-MIT-pink)

![tf-k8s-launcher](https://github.com/YashIndane/tf-k8s-launcher/assets/53041219/ae1d6f35-9ce0-4904-bc4e-ae74a9c6168e)

## Usage
```
$ sudo terraform init

$ sudo terraform validate

$ sudo terraform apply -var="worker_node_count=<COUNT>" -auto-approve
```
