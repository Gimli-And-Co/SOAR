resource "google_compute_network" "default" {
  name                    = "custom-network1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "192.168.0.0/24"
  network       = google_compute_network.default.self_link
}

resource "google_compute_firewall" "http-nginx" {
  name          = "http-nginx"
  network       = google_compute_network.default.name
  target_tags   = ["nginx"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "ssh-nginx" {
  name          = "ssh-nginx"
  network       = google_compute_network.default.name
  target_tags   = ["nginx"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "nginx" {
  name                    = "nginx"
  machine_type            = "n1-standard-1"
  tags                    = ["nginx"]
  metadata_startup_script = file("${path.module}/scripts/install-nginx.sh")
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  zone = "europe-west1-b"
  network_interface {
    subnetwork = "subnet1"
    access_config {
      // Ephemeral IP : The Ip address will be available until the instance is alive, when the stack is destroy and apply again, the public Ip is a new one
    }
  }
}

/* 

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
} */


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
