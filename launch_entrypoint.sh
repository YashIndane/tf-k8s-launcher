#!/bin/bash

#Entrypoint script for container to launch k8s cluster using Terraform.

while getopts a:b:c:d:e:f:g:h:i:j:k:l:m: flag
do
	case "${flag}" in
		a) c=${OPTARG};;
		b) ak=${OPTARG};;
		c) sk=${OPTARG};;
		d) reg=${OPTARG};;
		e) mami=${OPTARG};;
		f) mit=${OPTARG};;
		g) sid=${OPTARG};;
		h) mvs=${OPTARG};;
		i) dn=${OPTARG};;
		j) wami=${OPTARG};;
		k) wit=${OPTARG};;
		l) wvz=${OPTARG};;
		m) us=${OPTARG};;
	esac
done

terraform init
terraform validate
terraform apply -var="worker_node_count=$c" \
	        -var="access_key=$ak" \
		-var="secret_key=$sk" \
		-var="region=$reg" \
		-var="k8s_master_ami=$mami" \
		-var="k8s_master_instance_type=$mit" \
		-var="subnet_id=$sid" \
		-var="k8s_master_volume_size=$mvs" \
		-var="device_name=$dn" \
		-var="k8s_worker_ami=$wami" \
		-var="k8s_worker_instance_type=$wit" \
		-var="k8s_worker_volume_size=$wvz" \
		-var="user=$us" \
		-auto-approve

sleep 14400
