# Cloud SQL

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  name             = "master-${random_id.db_name_suffix.hex}"
  region           = "europe-west4"
  database_version = "POSTGRES_11"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_size         = "100"
    
    backup_configuration {
      enabled = true
    }
    
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.private_network.id
      // "projects/${var.project_id}/global/networks/default"
    }

    location_preference {
      zone = "europe-west4-a"
    }
  }
}

resource "google_sql_user" "postgres_user" {
  depends_on = [
    google_sql_database_instance.master
  ]
  name     = var.db_user_username
  instance = google_sql_database_instance.master.name
  password = var.db_user_password
}

resource "google_sql_database" "backendDB" {
  depends_on = [
    google_sql_user.postgres_user
  ]
  name     = var.db_name
  instance = google_sql_database_instance.master.name
}

/*resource "google_cloud_run_service" "run" {
    name="socialmedia"
    location = "us-central1"
    template {
        spec {
            containers {
                image = "gcr.io/${var.project_name}/socialmedia:latest"
                ports {
                    container_port = 5000
                }
                env {
                    name="ENV"
                    value = "production"
                }
                env {
                    name="DB_HOST"
                    value = "35.204.24.131"
                }
                env {
                    name="JWT_KEY"
                    value = var.jwt_key
                }
                env {
                    name="DB_URL"
                    value = "postgresql://${var.database_user}:${var.database_password}@/socialmedia?host=/cloudsql/${google_sql_database_instance.instance.connection_name}"
                }
            }
        }
        metadata {
            annotations = {
                "run.googleapis.com/cloudsql-instances"=google_sql_database_instance.instance.connection_name
            }
        }
    }
}*/

# Cloud SQL replica

/*resource "google_sql_database_instance" "replica" {
  name                 = "replica-${random_id.db_name_suffix.hex}"
  master_instance_name = "${var.project_id}:${google_sql_database_instance.master.name}"
  region               = "europe-west4"
  database_version     = "POSTGRES_11"

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    //google_sql_dattabase_instance.master  
  ]

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = "100"
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.private_network.id
      //"projects/${var.project_id}/global/networks/default"
    }
    location_preference {
      zone = "europe-west4-a"
    }
  }
}*/