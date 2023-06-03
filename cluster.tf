#Creating security group of K8S Master Node
resource "aws_security_group" "k8s_master_security_group" {
  name        = "k8s-master-security-group"
  description = "Allow opening of required ports for cluster operation and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ETCD Server"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet Health Check"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Controller Manager"
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Read Only Kubelet API"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Creating security group for K8S Worker Nodes
resource "aws_security_group" "k8s_worker_security_group" {
  name        = "k8s-worker-security-group"
  description = "Allow required port openings for cluster operation and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet Health Check"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "External Apps connectivity"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Read Only Kubelet API"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Creating and Provisioning K8S Master Node
resource "aws_instance" "k8s_master" {
  depends_on = [
    aws_security_group.k8s_master_security_group,
    aws_security_group.k8s_worker_security_group
  ]
  ami                    = var.k8s_master_ami
  instance_type          = var.k8s_master_instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_master_security_group.id]

  root_block_device {
    volume_size = var.k8s_master_volume_size
  }

  tags = {
    Name = var.k8s_master_name
  }

  provisioner "remote-exec" {
    inline = ["echo K8S MASTER READY"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ANSIBLE_BECOME_METHOD=sudo ANSIBLE_BECOME_ASK_PASS=False ansible-playbook -u ${var.user} -i '${self.public_ip},' --private-key ${var.private_key_path} multinode-k8s-cluster-on-AWS/setup-master.yml --become -v"
  }
}


#Creating and Provisioning K8S Worker Nodes
resource "aws_instance" "k8s_workers" {
  depends_on = [
    aws_instance.k8s_master
  ]
  count                  = var.worker_node_count
  ami                    = var.k8s_worker_ami
  instance_type          = var.k8s_worker_instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_worker_security_group.id]

  root_block_device {
    volume_size = var.k8s_worker_volume_size
  }

  tags = {
    Name = "k8s-worker-${count.index}"
  }

  provisioner "remote-exec" {
    inline = ["echo K8S WORKER - ${count.index} READY"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ANSIBLE_BECOME_METHOD=sudo ANSIBLE_BECOME_ASK_PASS=False ansible-playbook -u ${var.user} -i '${self.public_ip},' --private-key ${var.private_key_path} multinode-k8s-cluster-on-AWS/setup-worker.yml --become -v"
  }
}
