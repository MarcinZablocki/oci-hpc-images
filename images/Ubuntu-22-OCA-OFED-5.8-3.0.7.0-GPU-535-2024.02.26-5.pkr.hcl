/* variables */

packer {
    required_plugins {
      oracle = {
        source = "github.com/hashicorp/oracle"
        version = ">= 1.0.3"
      }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
    }
}

variable "image_id" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaaxauxzsyqlldmew5bh4xhw6r5k7b5jjcunjkalzgdgtyeqkv24gaa"
}

variable "image_base_name" {
  type    = string
  default = "Ubuntu-22-OCA-OFED-5.8-3.0.7.0-GPU-535-2024.02.26-5"
}

variable "build_options" {
  type    = string
  default = "noselinux,nomitigations,upgrade,openmpi,nvidia,enroot,monitoring,benchmarks,networkdevicenames,use_plugins"
}

variable "build_groups" {
  default = [ "kernel_parameters", "oci_hpc_packages", "mofed_58_3070", "hpcx_2131", "openmpi_414", "nvidia_535", "nvidia_cuda_12_2" , "use_plugins" ]
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ad" {
  type    = string
}

variable "compartment_ocid" {
  type    = string
}

variable "shape" {
  type    = string

}

variable "subnet_ocid" {
  type    = string
}

/*
uncomment access_cfg_file, access_cfg_file_account, region  
and comment use_instance_principals when using API key authentication 
both as variable AND in the source block
*/

/* variable "region" {
  type    = string
}

variable "access_cfg_file" {
  type    = string
}

variable "access_cfg_file_account" {
  type    = string

*/ 

source "oracle-oci" "oracle" {
  availability_domain = var.ad
  base_image_ocid     = var.image_id
  compartment_ocid    = var.compartment_ocid
  image_name          = local.build_name
  shape               = var.shape
  shape_config        { ocpus = "8" }
  ssh_username        = var.ssh_username
  subnet_ocid         = var.subnet_ocid
  user_data_file = "../files/user_data.txt"
  disk_size           = 60
  use_instance_principals = "true"
  ssh_timeout         = "90m"
  instance_name       = "HPC-ImageBuilder-${local.build_name}"
# access_cfg_file     = var.access_cfg_file
# access_cfg_file_account = var.access_cfg_file_account
# region              = var.region
}

locals {
  ansible_args        = "options=[${var.build_options}]"
  ansible_groups      = "${var.build_groups}"
  build_name          = "${var.image_base_name}"
}

build {
  name    = "buildname"
  sources = ["source.oracle-oci.oracle"]

  provisioner "ansible" {
    playbook_file   = "/home/ubuntu/Images/ansible/main.yml"
    extra_arguments = [ "-e", local.ansible_args]
    groups = local.ansible_groups
    user = "ubuntu"
  }

  provisioner "shell" {
    inline = ["rm -rf $HOME/~*", "sudo /usr/libexec/oci-image-cleanup --force"]
  }
}
