provider "google" {
credentials = "${file("credentials.json")}"
project = "ac-shared-playground"
region = "us-central1"
}
