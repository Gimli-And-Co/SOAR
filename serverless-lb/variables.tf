variable "project_id" {
  description = "plat-332317"
  type        = string
}

variable "name" {
  description = "serverless-lb"
  type        = string
}

variable "image" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-v1:tag1"
}