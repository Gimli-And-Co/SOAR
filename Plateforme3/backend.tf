# # # # # #
# Backend #
# # # # # #

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

resource "google_cloud_run_service" "backend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name     = "${var.name_backend}--${each.value}"
  location = each.value
  project  = var.project_id

  depends_on = [
    google_project_service.run_api
  ]

  template {
    spec {
      containers {
        image = var.image_back
        ports {
          container_port = "8080"
        }
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.masterv2.self_link
        }
        env {
          name  = "DB_USERNAME"
          value = var.db_user_username
        }
        env {
          name  = "DB_PWD"
          value = var.db_user_password
        }
        env {
          name  = "DB_DATABASE"
          value = "backendDB"
        }
        env {
          name  = "DB_PORT"
          value = "5432"
        }

      }
    }

  }

  metadata {
    annotations = {
      "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.masterv2.connection_name
    }
  }
}

resource "google_cloud_run_service_iam_member" "backend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  location = google_cloud_run_service.backend[each.key].location
  project  = google_cloud_run_service.backend[each.key].project
  service  = google_cloud_run_service.backend[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "backend" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each              = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name                  = "${var.name_backend}--neg--${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.backend[each.key].location
  cloud_run {
    service = google_cloud_run_service.backend[each.key].name
  }
}


module "lb-http-backend" {
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
