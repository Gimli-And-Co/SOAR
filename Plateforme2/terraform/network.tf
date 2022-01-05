/* resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
} */

/* resource "google_compute_subnetwork" "private-subnet" {
  depends_on = [google_compute_network.vpc]

  name                     = "${var.name}-private-subnet"
  ip_cidr_range            = "10.0.0.0/8"
  network                  = google_compute_network.vpc.name
  region                   = var.region
  private_ip_google_access = "true"
}

resource "google_compute_address" "nat-ip" {
  name = "${var.name}-nap-ip"
  project = var.project_name
  region  = var.region
}# create a nat to allow private instances connect to internet
resource "google_compute_router" "nat-router" {
  name = "${var.name}-nat-router"
  network = google_compute_network.vpc.name
}
resource "google_compute_router_nat" "nat-gateway" {
  name = "${var.name}-nat-gateway"
  router = google_compute_router.nat-router.name
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ google_compute_address.nat-ip.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
  depends_on = [ google_compute_address.nat-ip ]
}
 */


// LB

resource "google_compute_http_health_check" "web" {
  name                = "tf-web-basic-check"
  check_interval_sec  = 5
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 5
}

resource "google_compute_target_pool" "web" {
  name = "tf-web-target-pool"
  # instances = ["${google_compute_instance.web[*].self_link}"]
  instances     = [google_compute_instance.web.self_link, google_compute_instance.web2.self_link]
  health_checks = [google_compute_http_health_check.web.name]
}

resource "google_compute_forwarding_rule" "web" {
  name       = "tf-web-forwarding-rule"
  target     = google_compute_target_pool.web.self_link
  port_range = "80"
}


resource "google_compute_firewall" "web" {
  name    = "tf-web-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_http_health_check" "api" {
  name                = "tf-api-basic-check"
  check_interval_sec  = 5
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 5
}

resource "google_compute_target_pool" "api" {
  name = "tf-api-target-pool"
  # instances = ["${google_compute_instance.api[*].self_link}"]
  instances     = [for i in concat(google_compute_instance.api, google_compute_instance.api2) : i.self_link]
  health_checks = [google_compute_http_health_check.api.name]
}

resource "google_compute_forwarding_rule" "api" {
  name       = "tf-api-forwarding-rule"
  target     = google_compute_target_pool.api.self_link
  port_range = "80"
}
resource "google_compute_firewall" "api" {
  name    = "tf-api-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["api"]
}


resource "google_compute_http_health_check" "db" {
  name                = "tf-db-basic-check"
  check_interval_sec  = 5
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 5
}

resource "google_compute_target_pool" "db" {
  name = "tf-db-target-pool"
  # instances = ["${google_compute_instance.db[*].self_link}"]
  instances     = [for i in google_compute_instance.db : i.self_link]
  health_checks = [google_compute_http_health_check.db.name]
}

resource "google_compute_forwarding_rule" "db" {
  name       = "tf-db-forwarding-rule"
  target     = google_compute_target_pool.db.self_link
  port_range = "5432"
}


resource "google_compute_firewall" "db" {
  name    = "tf-db-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db"]
}


