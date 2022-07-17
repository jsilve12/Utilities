module "api" {
  source = "./api"
  image = var.image
}

module "setup" {
  source = "./setup"
  image = var.image
}
