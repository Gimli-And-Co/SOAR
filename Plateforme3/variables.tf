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

# Backend
/*locals {
  dbip = google_sql_database_instance.ip_configuration.private_network
  dbname = google_sql_database.name
}*/

variable "db_ip" {
  type = string
  default = "wrong"
  //default = google_compute_network.private_network.id
}

variable "db_name" {
  type = string
  default = "backendDB"
}

variable "db_user_username" {
  type = string
  default = "postgres_user"
}

variable "db_user_password" {
  type = string
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
  default = "someIP"
  //default     = "http://${module.lb-http.external_ip}"
}

variable "image_front" {
  description = "container image to deploy"
  default     = "gcr.io/plat-332317/soar-webapp-v1:tag1"
}

variable "image_back" {
  description = "container image to deploy"
default     = "gcr.io/plat-332317/A CHANGER"
}

/*variable "main_pwd" {
  type = string
  default = "postgres"
}*/