# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
data "google_client_config" "default" {
}

provider "kubernetes" {
  host = "https://${var.host}"

  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = "https://${var.host}"

    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${var.host}"
  load_config_file       = false

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}