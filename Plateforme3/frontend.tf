# # # # # # #
# Frontend  #
# # # # # # #

data "google_cloud_run_locations" "default" {}

resource "google_cloud_run_service" "frontend" {
  name     = "${var.name}--${random_id.db_name_suffix.hex}"
  location = "europe-west1"
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image_front
      }
    }
  }

  depends_on = [
      google_project_service.run_api
  ]
}

resource "google_cloud_run_service_iam_member" "frontend" {
  location = google_cloud_run_service.frontend.location
  project  = google_cloud_run_service.frontend.project
  service  = google_cloud_run_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "frontend" {
  name                  = "${var.name_backend}--neg--${random_id.db_name_suffix.hex}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.frontend.location
  cloud_run {
    service = google_cloud_run_service.frontend.name
  }
}

/*module "lb-http-frontend" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 4.5"

  project = var.project_id
  name    = var.name

  ssl                             = false
  managed_ssl_certificate_domains = []
  https_redirect                  = false
  backends = {
    default = {
      description            = null
      enable_cdn             = false
      custom_request_headers = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.frontend :
        {
          group = neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
      security_policy = null
    }
  }
}*/
