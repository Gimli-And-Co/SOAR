# ------------------------------
# Ansible
/*resource "google_compute_instance" "initDB" {
  name = "initDB"
  machine_type = "f1-micro"
  zone = "europe-west4-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // ca sera pour une adress ip externe
    }
  }

  
# Execute a python script to config DB
  provisioner "local-exec" {
    command = "python ${python-script}"
  }

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
  value = "${google_compute_instance.initDB.network_interface.0.access_config.0.nat_ip}"
}*/