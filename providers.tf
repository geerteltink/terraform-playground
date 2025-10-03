terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.0"
    }
    kubectl = {
      source  = "registry.terraform.io/gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
  }
}

provider "kubectl" {
  config_path    = "~/.kube/config"
}
