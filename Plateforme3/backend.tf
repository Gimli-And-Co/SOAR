# # # # # #
# Backend #
# # # # # #

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_cloud_run_service" "backend" {
  name     = "${var.name_backend}--${random_id.db_name_suffix.hex}"
  location = "europe-west1"
  project  = var.project_id

  depends_on = [
    google_project_service.run_api,
    google_sql_database_instance.masterv2,
    google_sql_database.backendDB
  ]

  template {
    spec {
      containers {
        image = var.image_back
        ports {
          container_port = "3000"
        }
        env {
          name  = "NODE_ENV"
          value = "production"
        }
        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.masterv2.ip_address.0.ip_address
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

  location = google_cloud_run_service.backend.location
  project  = google_cloud_run_service.backend.project
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.backend.location
  project     = google_cloud_run_service.backend.project
  service     = google_cloud_run_service.backend.name
  policy_data = data.google_iam_policy.noauth.policy_data
}


resource "google_compute_region_network_endpoint_group" "backend" {
  name                  = "${var.name_backend}--neg--${random_id.db_name_suffix.hex}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.backend.location
  cloud_run {
    service = google_cloud_run_service.backend.name
  }
}


/*module "lb-http-backend" {
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
}*/
