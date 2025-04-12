# Packer Demo

This repository is part of the Hashicorp Meetup - 12th April 2025


## Packer Template: basic-aws.pkr.hcl

This Packer template builds a basic Amazon Machine Image (AMI) using **Amazon Linux 2023** and includes a simple shell provisioner.

### Steps

- **Creates an EC2 AMI** in the `ap-south-1` (Mumbai) AWS region.
- Uses the most recent official Amazon Linux 2023 base image.
- Provisions the instance by:
  - Updating all packages.
  - Installing `htop`.
- Automatically **deregisters** and **cleans up** old AMIs with the same name.


### Plugin Setup

```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
```

This block ensures Packer uses the official **Amazon plugin** for building AMIs.


### Source Configuration

```hcl
source "amazon-ebs" "create-image" {
  ...
}
```

**Key parts:**

- `ami_name`: Sets the name of the created AMI (`basic-image-demo`).
- `source_ami_filter`: Searches for the latest **Amazon Linux 2023** image.
- `force_deregister`: Removes existing AMIs with the same name.
- `force_delete_snapshot`: Deletes any associated snapshots.
- `ssh_username`: For Amazon Linux, this is usually `ec2-user`.


### Build & Provision

```hcl
build {
  sources = ["source.amazon-ebs.create-image"]

  provisioner "shell" {
    inline = ["sudo dnf update -y", "sudo dnf install htop -y"]
  }
}
```

This build block tells Packer to:

- Launch the EC2 instance.
- Run shell commands to update the system and install `htop`.
- Create and save the configured AMI.


### How to Run

1. Make sure you have [Packer installed](https://developer.hashicorp.com/packer/downloads).
2. Run the following in your terminal:

```bash
packer init .
packer build .
```

## Packer Template: basic-linode.pkr.hcl


This Packer configuration creates a custom **Linode image** using **CentOS Stream 9** and includes basic provisioning steps.



### Steps

- Launches a temporary Linode instance in the **ap-south** region.
- Uses the official `linode/centos-stream9` base image.
- Provisions the instance by:
  - Updating the system.
  - Installing `epel-release`.
  - Installing `htop`.
- Saves the machine as a reusable **Linode image** labeled `basic-image-demo`.


### Plugin Setup

```hcl
packer {
  required_plugins {
    linode = {
      version = ">= 1.0.1"
      source  = "github.com/linode/linode"
    }
  }
}
```

This ensures Packer uses the **official Linode plugin**.


### Authentication

```hcl
variable "linode_api_token" {
  type        = string
  default     = "${env("LINODE_API_TOKEN")}"
  description = "Linode API token"
}
```

The template pulls your **Linode API token** from the `LINODE_API_TOKEN` environment variable.  
You can export it in your shell like this:

```bash
export LINODE_API_TOKEN=your_token_here
```


### Source Configuration

```hcl
source "linode" "create-image" {
  ...
}
```

**Key parts:**

- `image`: The base image used (`linode/centos-stream9`)
- `image_label`: Name for the custom image created by Packer
- `instance_label`: Name of the temporary Linode instance used during build
- `instance_type`: Size of the VM (`g6-standard-1`)
- `region`: Location of the instance (here, `ap-south`)
- `ssh_username`: User to connect as (`root`)


### Build & Provision

```hcl
build {
  sources = ["source.linode.create-image"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y epel-release",
      "sudo dnf install htop -y"
    ]
  }
}
```

This block tells Packer to:
- Spin up the Linode instance
- Provision it using shell commands
- Create a reusable custom image


### How to Run

1. Install [Packer](https://developer.hashicorp.com/packer/downloads) and the [Linode CLI](https://www.linode.com/docs/products/tools/cli/)
2. Set your Linode API token:
   ```bash
   export LINODE_API_TOKEN=your_token_here
   ```
3. Run the build:
```bash
packer init .
packer build .
```


# License
MIT