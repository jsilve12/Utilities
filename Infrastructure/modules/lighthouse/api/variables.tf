variable "replicas" {
  type = number
  default = 1
}

variable "image" {
  type = string
}

variable "root" {
  type = string
  default = "jonathansilverstein.us."
}

variable "zone" {
  type = string
  default = "personal-website"
}
