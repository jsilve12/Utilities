terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.64.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.0"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  zone = var.zone
}

data "google_client_config" "default" {}

resource "google_container_cluster" "default" {
  name = var.cluster-name
  location = "us-central1"
  enable_autopilot = true
  vertical_pod_autoscaling {
    enabled = true
  }
}

provider "kubernetes" {
  host = "https://${resource.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    resource.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${resource.google_container_cluster.default.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      resource.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
    )
  }
}

module "kubernetes" {
  source = "./modules/kubernetes"
}

module "lighthouse" {
  source = "./modules/lighthouse"
  image = "gcr.io/personal-project-289714/lighthouse:20220719224319"
}
