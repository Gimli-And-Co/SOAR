provider "google" {
  project = "pure-archive-330307"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  
  
  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

    metadata_startup_script = file("${path.module}/scripts/frontend-startup.sh")

    // Apply the firewall rule to allow external IPs to access this instance
    tags = ["http-server"]
}


resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

// Forwarding rule for External Network Load Balancing using Backend Services
/*resource "google_compute_forwarding_rule" "default" {
  provider              = google-beta
  name                  = "website-forwarding-rule"
  region                = "us-central1"
  port_range            = 80
  backend_service       = google_compute_region_backend_service.backend.id
}

resource "google_compute_region_backend_service" "backend" {
  provider              = google-beta
  name                  = "website-backend"
  region                = "us-central1"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.hc.id]
}

resource "google_compute_region_health_check" "hc" {
  provider           = google-beta
  name               = "check-website-backend"
  check_interval_sec = 1
  timeout_sec        = 1
  region             = "us-central1"

  tcp_health_check {
    port = "80"
  }
}*/
