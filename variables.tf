variable "access_key" {
  description = "AWS Access Key"
  type        = string
  default     = ""
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region to use for infra"
  type        = string
  default     = "ap-south-1"
}

variable "k8s_master_ami" {
  description = "K8s master AMI"
  type        = string
  default     = "ami-02d508880f5861d90"
}

variable "k8s_master_instance_type" {
  description = "K8s master node instance type"
  type        = string
  default     = "t2.medium"
}

variable "subnet_id" {
  description = "Subnet id to launch the cluster"
  type        = string
  default     = "subnet-0b1382acff5d2930a"
}

variable "k8s_master_volume_size" {
  description = "K8s master volume size"
  type        = string
  default     = "20"
}

variable "device_name" {
  description = "Device name to use for mounting on cluster nodes"
  type        = string
  default     = "/dev/xvda"
}

variable "k8s_worker_ami" {
  description = "K8s worker node AMI"
  type        = string
  default     = "ami-02d508880f5861d90"
}

variable "k8s_worker_instance_type" {
  description = "K8s worker node instance type"
  type        = string
  default     = "t2.medium"
}

variable "k8s_worker_volume_size" {
  description = "K8s worker node volume size"
  type        = string
  default     = "20"
}

variable "worker_node_count" {
  description = "Total worker node count in cluster"
  type        = number
  default     = 2
}

variable "user" {
  description = "User name used to login to cluster nodes for configuration"
  type        = string
  default     = "ec2-user"
}
