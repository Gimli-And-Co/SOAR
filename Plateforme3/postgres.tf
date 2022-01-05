# Cloud SQL

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "masterv2" {
  name             = "masterv2-${random_id.db_name_suffix.hex}"
  region           = "europe-west4"
  database_version = "POSTGRES_11"

  //depends_on = [google_service_networking_connection.private_vpc_connection]
  deletion_protection=false
  settings {
    tier              = "db-n1-standard-4"
    availability_type = "REGIONAL"
    disk_size         = "10"

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
      //private_network = google_compute_network.private_network.id
      // "projects/${var.project_id}/global/networks/default"
    }

    location_preference {
      zone = "europe-west4-a"
    }
  }
}

resource "google_sql_user" "postgres_user" {
  depends_on = [
    google_sql_database_instance.masterv2
  ]
  name     = var.db_user_username
  instance = google_sql_database_instance.masterv2.name
  password = var.db_user_password
}

resource "google_sql_database" "backendDB" {
  depends_on = [
    google_sql_user.postgres_user
  ]
  name     = var.db_name
  instance = google_sql_database_instance.masterv2.name
}


# Cloud SQL replica

/*resource "google_sql_database_instance" "replica" {
  name                 = "replica-${random_id.db_name_suffix.hex}"
  master_instance_name = "${var.project_id}:${google_sql_database_instance.masterv2.name}"
  region               = "europe-west4"
  database_version     = "POSTGRES_11"

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    //google_sql_dattabase_instance.masterv2  
  ]

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = "10"
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