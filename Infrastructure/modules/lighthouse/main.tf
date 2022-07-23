module "workload-identity" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name = "lighthouse-iam"
  namespace = "lighthouse"
  project_id = "personal-project-289714"
  roles = ["roles/storage.admin", "roles/datastore.user"]
}

module "api" {
  source = "./api"
  image = var.image
}

module "setup" {
  source = "./setup"
  image = var.image
}

module "collections" {
  source = "./collections"
  image = var.image
}

module "etl" {
  source = "./etl"
  image = var.image
}
