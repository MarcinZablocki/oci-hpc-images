
# Introduction
This repository contains templates for generating HPC images compatible with Oracle Cloud cluster networks and compute clusters.
They are highly customizable, providing abiility to add and remove components.
# Building image using packer

> Copy images/default.pkr.hcl.example file to images/default.pkr.hcl
> provide values for the variables via -var="variable=value" or -var-file=defaults.pkr.hcl 

```
cd images
packer build -var-file=defaults.pkr.hcl template.pkr.hcl
```
# Customization
Customization of the image is controlled by two packer variables *build_options* and *build_groups*

build_options

: Defines features to be enabled in the image
: `default = "noselinux,nomitigations,upgrade,openmpi,nvidia,enroot,monitoring,benchmarks,networkdevicenames"`

| Parameter | Description |
| ----------- | ----------- |
| noselinux | Disabled SELINUX on Enterprise Linux distributions |
| nomitigations | Disables Spectre/Meltdown mitigation via GRUB command line |
| upgrade | Ensure upgrade of all packages from the base image |
| openmpi | Install OpenMPI. Version defined by the build_group openmpi_xxx |
| nvidia | Install NVidia drivers defined by the build_group nvidia_xxx |
| enroot | Install enroot container runtime |
| monitoring | Install monitoring agent and collectors |
| benchmarks | Install various benchmarks (OSU/NCCL/Stream) |
| networkdevicenames | Install udev rules for correct device naming |

build_groups

: Defines component versions and variables

`default = [ "kernel_parameters", "oci_hpc_packages", "mofed_54_3681", "hpcx_2131", "openmpi_414", "nvidia_515", "nvidia_cuda_11_7" ]`
