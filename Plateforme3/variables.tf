variable "project_id" {
  description = "GCP project id"
  type        = string
  default = "plat-332317"
}

variable "name" {
  description = "LB name"
  type        = string
  default = "serverless-lb"
}

variable "image" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-v1:tag1"
}

variable "main_pwd" {
  type = string
  default = "postgres"
}