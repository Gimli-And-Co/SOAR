# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
  default     = "vertical-planet-334017"

}

variable "region" {
  description = "The region to create the resources in."
  type        = string
  default     = "europe-west1"

}

variable "zone" {
  description = "The availability zone to create the sample compute instances in. Must within the region specified in 'var.region'"
  type        = string
  default     = "europe-west1-b"

}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
  default     = "soar"
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key used to connect to the instance"
  default     = "~/.ssh/id_rsa"
}

variable "frontend_script" {
  description = "Frontend script"
  type        = string
  default     = "./scripts/frontend-startup2.sh"
}
