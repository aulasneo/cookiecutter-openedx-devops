#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#-----------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    local = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    random = {
      source  = "hashicorp/random"
      version = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> {{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "{{ cookiecutter.terraform_provider_hashicorp_helm_version }}"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    }
  }
}
