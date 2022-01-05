# # # # # # #
# Frontend  #
# # # # # # #

data "google_cloud_run_locations" "default" {} // also used for backend

resource "google_cloud_run_service" "frontend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name     = "${var.name}--${each.value}"
  location = each.value
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image_front
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "frontend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  location = google_cloud_run_service.frontend[each.key].location
  project  = google_cloud_run_service.frontend[each.key].project
  service  = google_cloud_run_service.frontend[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "frontend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each              = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name                  = "${var.name}--neg--${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.frontend[each.key].location
  cloud_run {
    service = google_cloud_run_service.frontend[each.key].name
  }
}

module "lb-http" {
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
    
    backend-lb = {
      description            = null
      enable_cdn             = false
      custom_request_headers = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.backend :
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
}
