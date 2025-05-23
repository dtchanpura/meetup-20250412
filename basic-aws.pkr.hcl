packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "create-image" {
  ami_name      = "basic-image-demo"
  instance_type = "t3.micro"
  region        = "ap-south-1"

  // Ref: https://docs.aws.amazon.com/linux/al2023/ug/ec2.html
  // Ref: https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#Images:visibility=public-images;imageName=:al2023-ami;ownerAlias=amazon;v=3;$case=tags:false%5C,client:false;$regex=tags:false%5C,client:false
  // source_ami = "ami-002f6e91abff6eb96"


  source_ami_filter {
    most_recent = true
    owners      = ["amazon"] # Amazon Linux's official AWS account
    filters = {
      virtualization-type = "hvm"
      root-device-type    = "ebs"
      name                = "al2023-ami-2023.*-kernel-6.1-*"
      architecture        = "x86_64"
    }
  }


  // Force Packer to first deregister an existing AMI if one with the same name already exists. Default false.
  force_deregister = true

  // Force Packer to delete snapshots associated with AMIs, which have been deregistered by force_deregister. Default false.
  force_delete_snapshot = true

  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.create-image"]

  provisioner "shell" {
    inline = ["sudo dnf update -y", "sudo dnf install htop -y"]
  }

}

