provider "google" {
  project = var.project_id
}

# Private network

/*resource "google_compute_network" "private_network" {
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
}*/


# Cloud SQL
/*
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

resource "google_sql_user" "main" {
  depends_on = [
    google_sql_database_instance.master
  ]
  name     = "main"
  instance = google_sql_database_instance.master.name
  password = var.main_pwd
}

resource "google_sql_database" "main" {
  depends_on = [
    google_sql_user.main
  ]
  name     = "main"
  instance = google_sql_database_instance.master.name
}

# Cloud SQL replica

resource "google_sql_database_instance" "replica" {
  name                 = "replica-${random_id.db_name_suffix.hex}"
  master_instance_name = "${var.project_id}:${google_sql_database_instance.master.name}"
  region               = "europe-west4"
  database_version     = "POSTGRES_11"

  depends_on = [google_service_networking_connection.private_vpc_connection]

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

# Config DB
# call ansible

# Cloud RUN

data "google_cloud_run_locations" "default" {}

resource "google_cloud_run_service" "default" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name     = "${var.name}--${each.value}"
  location = each.value
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }

  /*metadata {
    annotations = {
      //"run.googleapis.com/cloudsql-instances" = google_sql_database_instance.master.connection_name
    }
  }*/
}

resource "google_cloud_run_service_iam_member" "default" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  location = google_cloud_run_service.default[each.key].location
  project  = google_cloud_run_service.default[each.key].project
  service  = google_cloud_run_service.default[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "default" {
  //for_each = toset(data.google_cloud_run_locations.default.locations)
  for_each              = toset([for location in data.google_cloud_run_locations.default.locations : location if can(regex("europe-(?:west|central|east)[1-2]", location))])
  name                  = "${var.name}--neg--${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.default[each.key].location
  cloud_run {
    service = google_cloud_run_service.default[each.key].name
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
        for neg in google_compute_region_network_endpoint_group.default :
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

# Open the URL of the webapp
provisioner "local-exec" {
  command = "chrome ${frontend_url}"
}