#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module Terraform provider configurations
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> {{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    local = {
      source  = "hashicorp/local"
      version = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    }
    random = {
      source  = "hashicorp/random"
      version = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "{{ cookiecutter.terraform_provider_hashicorp_ssh_version }}"
    }
  }
}
