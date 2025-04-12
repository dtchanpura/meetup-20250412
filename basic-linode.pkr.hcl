packer {
  required_plugins {
    linode = {
      version = ">= 1.0.1"
      source  = "github.com/linode/linode"
    }
  }
}

// https://developer.hashicorp.com/packer/integrations

variable "linode_api_token" {
  type        = string
  default     = "${env("LINODE_API_TOKEN")}"
  description = "Linode API token"
}

source "linode" "create-image" {
  image          = "linode/centos-stream9"
  image_label    = "basic-image-demo"
  
  instance_label = "tmp-packer-centos-stream9-demo"
  instance_type  = "g6-standard-1"
  linode_token   = "${var.linode_api_token}"
  region         = "ap-south"
  ssh_username   = "root"
//   ssh_private_key_file = "/home/darshil/.ssh/id_ed25519"
}

build {
  sources = ["source.linode.create-image"]

  provisioner "shell" {
    inline = ["sudo dnf update -y", "sudo dnf install -y epel-release", "sudo dnf install htop -y"]
  }
}