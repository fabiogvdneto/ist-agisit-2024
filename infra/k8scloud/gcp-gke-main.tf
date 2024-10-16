# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "workers_count" {
  type = number
}

variable "project_name" {
  type = string
}

variable "gcr-repo" {
  type = string
}

variable "gcr-region" {
  type = string
}

# Configure Kubernetes provider with OAuth2 access token
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
  depends_on = [module.gcp_gke]
}


#####################################################################
# Modules for Provisioning and Deployment
#####################################################################

# The module in folder 'gcp_gke' defines the Kubernetes Cluster
module "gcp_gke" {
  source   = "./gcp_gke"
  project = var.project
  project_name = var.project_name
  region = var.region
  workers_count = var.workers_count
}
# The module in folder 'gcp_k8s' defines the Pods and Services
module "gcp_k8s" {
  source   = "./gcp_k8s"
  host     = module.gcp_gke.host
  gcr-repo = var.gcr-repo
  gcr-region = var.gcr-region
  project = var.project
  client_certificate     = module.gcp_gke.client_certificate
  client_key             = module.gcp_gke.client_key
  cluster_ca_certificate = module.gcp_gke.cluster_ca_certificate
}
