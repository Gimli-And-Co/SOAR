
/* 
provider "google" {
  project = "pure-archive-330307"
  region  = "europe-west1"
} */
provider "google" {
  region  = var.region
  project = var.project
}
