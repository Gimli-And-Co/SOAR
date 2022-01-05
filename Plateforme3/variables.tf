variable "project_id" {
  description = "GCP project id"
  type        = string
  default     = "plat-332317"
}

variable "name" {
  description = "LB name frontend"
  type        = string
  default     = "frontend"
}

variable "name_backend" {
  description = "LB name backend"
  type        = string
  default     = "backend"
}

# Backend

variable "db_ip" {
  type    = string
  default = "wrong"
}

variable "db_name" {
  type    = string
  default = "backendDB"
}

variable "db_user_username" {
  type    = string
  default = "postgres_user"
}

variable "db_user_password" {
  type    = string
  default = "postgres"
}

# Python
variable "python_script" {
  description = "Script python to config the DB"
  type        = string
  default     = "config-db.py"
}

# Final
variable "frontend_url" {
  description = "URL of the frontend page"
  type        = string
  default     = "someIP"
  //default     = "http://${module.lb-http.external_ip}"
}

variable "image_front" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-v1:latest"
}

variable "image_back" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-backend:v5"
}
