
variable "project_name" {
  description = "The ID of the Google Cloud project"
  type        = string
  default     = "vertical-planet-334017"
}

variable "region" {
  default = "europe-west1"
}

variable "zone" {
  default = "europe-west1-b"
}

variable "zone2" {
  default = "europe-west1-c"
}

variable "name" {
  default = "soar2"
}


variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "google-compute-engine-account.json"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa"
}

variable "ssh_user" {
  default = "pyrd"
}

variable "internal_lb_name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
  default     = "lb-api"
}

data "google_compute_image" "debian" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

