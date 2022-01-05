terraform {
  required_version = ">= 0.14"

  required_providers {
    google = ">= 3.3"
  }
}

provider "google" {
  project = "plat-332317"
}

# Private network
/*
resource "google_compute_network" "private_network" {
  project = "plat-332317"
  provider = google

  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google

  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
*/

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service_front" {
  name = "appfront"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "gcr.io/plat-332317/soar-webapp-v1:tag1"
      }
    }
  }

  metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        //"run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postgres.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled & the private subnet
  depends_on = [
    google_project_service.run_api,
    //google_service_networking_connection.private_vpc_connection
  ]
}

/*resource "google_cloud_run_service" "run_service_back" {
  name = "appback"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "gcr.io/plat-332317/soar-webapp-backend:v1"
      }
    }
  }

  metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postgres.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled & the private subnet
  depends_on = [
    google_project_service.run_api,
    google_service_networking_connection.private_vpc_connection
  ]
}*/


resource "random_id" "db_name_suffix" {
  byte_length = 4
}

/*resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.postgres.name
}

# Create the Cloud SQL service
resource "google_sql_database_instance" "postgres" {
  name             = "private-instance-${random_id.db_name_suffix.hex}"
  region           = "europe-west1"
  database_version = "POSTGRES_11"
  
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }

  deletion_protection  = "false"
}

resource "google_sql_user" "db_user" {
  name     = "Loki"
  instance = google_sql_database_instance.postgres.name
  password = "lokicantdie"
}*/

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service_front.name
  location = google_cloud_run_service.run_service_front.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}