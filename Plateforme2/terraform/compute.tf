# web (nginx reverse proxies)
resource "google_compute_instance" "web" {

  name         = "tf-web-zone-1"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["web"]

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

resource "google_compute_instance" "web2" {

  name         = "tf-web-zone-2"
  machine_type = "e2-standard-2"
  zone         = var.zone2
  tags         = ["web"]

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

# api (Node.js)
resource "google_compute_instance" "api" {
  count        = 2
  name         = "tf-api-${count.index}"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["api"]

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

resource "google_compute_instance" "api2" {
  count        = 2
  name         = "tf-api-${count.index}"
  machine_type = "e2-standard-2"
  zone         = var.zone2
  tags         = ["api"]

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

