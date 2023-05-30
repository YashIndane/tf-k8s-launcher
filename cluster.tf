#Creating and Provisioning K8S Master Node

resource "aws_instance" "k8s_master" {
  ami             = var.k8s_master_ami
  instance_type   = var.k8s_master_instance_type
  subnet_id       = var.subnet_id
  key_name        = var.key_name
  security_groups = var.k8s_master_security_group_id

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
  count           = var.worker_node_count
  ami             = var.k8s_worker_ami
  instance_type   = var.k8s_worker_instance_type
  subnet_id       = var.subnet_id
  key_name        = var.key_name
  security_groups = var.k8s_worker_security_group_id

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
