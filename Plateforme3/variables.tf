variable "project_id" {
  description = "GCP project id"
  type        = string
  default     = "plat-332317"
}

variable "name" {
  description = "LB name"
  type        = string
  default     = "frontend"
}

variable "frontend_url" {
  description = "URL of the frontend page"
  type        = string
  default     = "http://${module.lb-http.external_ip}"
}

variable "image" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-v1:tag1"
}

/*variable "main_pwd" {
  type = string
  default = "postgres"
}*/