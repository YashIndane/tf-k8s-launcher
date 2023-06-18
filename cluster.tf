#Creating SSH keys for K8S Master and Worker Nodes
resource "tls_private_key" "k8s_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated_k8s_ssh_key" {
  depends_on = [
    tls_private_key.k8s_ssh_key
  ]
  key_name   = "gen_k8s_ssh_key"
  public_key = tls_private_key.k8s_ssh_key.public_key_openssh

  #Store private key
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.k8s_ssh_key.private_key_pem}' > k8s_ssh_key.pem
      chmod 400 k8s_ssh_key.pem
    EOT
  }
}


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
    aws_security_group.k8s_worker_security_group,
    aws_key_pair.generated_k8s_ssh_key
  ]
  ami                    = var.k8s_master_ami
  instance_type          = var.k8s_master_instance_type
  subnet_id              = var.subnet_id
  key_name               = "gen_k8s_ssh_key"
  vpc_security_group_ids = [aws_security_group.k8s_master_security_group.id]

  root_block_device {
    volume_size = var.k8s_master_volume_size
  }

  tags = {
    Name = "k8s-master"
  }

  provisioner "remote-exec" {
    inline = ["echo K8S MASTER READY"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = tls_private_key.k8s_ssh_key.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ANSIBLE_BECOME_METHOD=sudo ANSIBLE_BECOME_ASK_PASS=False ansible-playbook -u ${var.user} -i '${self.public_ip},' --private-key k8s_ssh_key.pem multinode-k8s-cluster-on-AWS/setup-master.yml --become -v"
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
  key_name               = "gen_k8s_ssh_key"
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
      private_key = tls_private_key.k8s_ssh_key.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ANSIBLE_BECOME_METHOD=sudo ANSIBLE_BECOME_ASK_PASS=False ansible-playbook -u ${var.user} -i '${self.public_ip},' --private-key k8s_ssh_key.pem multinode-k8s-cluster-on-AWS/setup-worker.yml --become -v"
  }
}


#Checking cluster status and details
resource "null_resource" "check_cluster_details" {
  depends_on = [
    aws_instance.k8s_workers
  ]

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo kubectl cluster-info",
      "sudo kubectl get nodes -o wide",
      "sudo kubectl get all --all-namespaces"
    ]
  }

  connection {
    host        = aws_instance.k8s_master.public_ip
    type        = "ssh"
    user        = var.user
    private_key = tls_private_key.k8s_ssh_key.private_key_pem
  }
}
