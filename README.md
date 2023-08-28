# tf-k8s-launcher

[![Launching K8s cluster](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml/badge.svg)](https://github.com/YashIndane/tf-k8s-launcher/actions/workflows/k8s_cluster_launch.yml) ![](https://img.shields.io/badge/Ansible-black?logo=ansible&logoColor=white) ![](https://img.shields.io/badge/AWS-yellow?logo=amazon&logoColor=white) ![](https://img.shields.io/badge/Terraform-purple?logo=terraform&logoColor=white) ![](https://img.shields.io/badge/Kubernetes-blue?logo=kubernetes&logoColor=white) ![](https://img.shields.io/badge/License-MIT-pink)

![tf-k8s-launcher](https://github.com/YashIndane/tf-k8s-launcher/assets/53041219/ae1d6f35-9ce0-4904-bc4e-ae74a9c6168e)

## Usage

### Pulling the image
```
$ sudo docker pull --platform linux/arm64/v8 docker.io/yashindane/tf-k8s-launcher:version
```

### Launching The K8S Cluster
```
$ sudo docker run --platform linux/arm64/v8 -dit --name <CONTAINER_NAME> yashindane/tf-k8s-launcher:version -a <WORKER_NODE_COUNT> -b '<ACCESS_KEY>' -c '<SECRET_KEY>' -d '<AWS_REGION>' -e '<K8S_MASTER_AMI>' -f '<K8S_MASTER_INSTANCE_TYPE>' -g '<SUBNET_ID>' -h '<K8S_MASTER_VOLUME_SIZE>' -i '<DEVICE_NAME>' -j '<K8S_WORKER_AMI>' -k '<K8S_WORKER_INSTANCE_TYPE>' -l '<K8S_WORKER_VOLUME_SIZE>' -m '<USER>'
```

| Flag | Description |
| --- | --- |
| -a | Worker node count |
| -b | AWS access key |
| -c | AWS secret key |
| -d | AWS region |
| -e | K8S master node AMI |
| -f | K8S master node instance type |
| -g | Subnet ID |
| -h | K8S master node volume size |
| -i | Device name (/dev/xvda) |
| -j | K8S worker node AMI |
| -k | K8S worker node instance type |
| -l | K8S worker node volume size | 
| -m | User (ec2-user) |

### Destroying The K8S Cluster
```
$ sudo docker exec -it <CONTAINER_NAME> terraform destroy -var="worker_node_count=<COUNT>" -var="access_key=<AK>" -var="secret_key=<SK>" -var="region=<REG>" -var="k8s_master_ami=<AMI>" -var="k8s_master_instance_type=<INSTANCE_TYPE>" -var="subnet_id=<SID>" -var="k8s_master_volume_size=<SIZE>" -var="device_name=<NAME>" -var="k8s_worker_ami=<AMI>" -var="k8s_worker_instance_type=<INSTANCE_TYPE>" -var="k8s_worker_volume_size=<SIZE>" -var="user=<USER>" -auto-approve
```


