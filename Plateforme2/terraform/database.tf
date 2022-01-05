
resource "google_compute_instance" "db" {
  count        = 2
  name         = "tf-db-${count.index}"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["db"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }

  service_account {
    scopes = ["compute-rw"]
  }

}