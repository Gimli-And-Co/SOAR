
# ------------------------------------------------------------------------------
# CREATE THE INTERNAL TCP LOAD BALANCER
# ------------------------------------------------------------------------------

module "lb" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/gruntwork-io/terraform-google-load-balancer.git//modules/internal-load-balancer?ref=v0.2.0"

  name    = var.name
  region  = var.region
  project = var.project

  backends = [
    {
      description = "Instance group for internal-load-balancer test"
      group       = google_compute_instance_group.api.self_link
    },
  ]

  # This setting will enable internal DNS for the load balancer
  service_label = var.name

  network    = module.vpc_network.network
  subnetwork = module.vpc_network.public_subnetwork

  health_check_port = 5000
  http_health_check = false
  target_tags       = [var.name]
  source_tags       = [var.name]
  ports             = ["5000"]

  custom_labels = var.custom_labels
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NETWORK TO DEPLOY THE RESOURCES TO
# ---------------------------------------------------------------------------------------------------------------------

module "vpc_network" {
  source = "github.com/gruntwork-io/terraform-google-network.git//modules/vpc-network?ref=v0.8.2"

  name_prefix = var.name
  project     = var.project
  region      = var.region

  cidr_block           = "10.1.0.0/16"
  secondary_cidr_block = "10.2.0.0/16"
}

# ------------------------------------------------------------------------------
# CREATE THE INSTANCE GROUP WITH A SINGLE INSTANCE
# ------------------------------------------------------------------------------

resource "google_compute_instance_group" "api" {
  project   = var.project
  name      = "${var.name}-instance-group"
  zone      = var.zone
  instances = [google_compute_instance.api.self_link]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance" "api" {
  project      = var.project
  name         = "${var.name}-api-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  # We're tagging the instance with the tag specified in the firewall rule
  tags = [
    var.name,
    module.vpc_network.private,
    module.vpc_network.public,
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  /* metadata_startup_script = file("${path.module}/scripts/backend-startup.sh") */
  /* metadata_startup_script = data.template_file.api_startup_script.rendered */
  /* metadata {
    startup-script = data.template_file.api_startup_script.rendered
  } */
  metadata = {
    startup-script = ("${file(var.frontend_script)}")
  }

  network_interface {
    network    = module.vpc_network.network
    subnetwork = module.vpc_network.public_subnetwork
  }
}

# ------------------------------------------------------------------------------
# CREATE THE PROXY INSTANCE
# ------------------------------------------------------------------------------

resource "google_compute_instance" "webapp" {
  project      = var.project
  name         = "${var.name}-webapp-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  # We're tagging the instance with the tag specified in the firewall rule
  tags = [
    var.name,
    module.vpc_network.public,
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = data.template_file.proxy_startup_script.rendered

  network_interface {
    network    = module.vpc_network.network
    subnetwork = module.vpc_network.public_subnetwork

    access_config {
      // Ephemeral IP
    }
  }

  /* provisioner "remote-exec" {
    script = data.template_file.proxy_startup_script.rendered

    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = var.username
      private_key = file(var.private_key_path)
    }
  } */
}

data "template_file" "proxy_startup_script" {
  template = file("${path.module}/scripts/frontend-startup.sh")

  # Pass in the internal DNS name and private IP address of the LB
  vars = {
    VUE_APP_APIURL = module.lb.load_balancer_domain_name
    ilb_ip         = module.lb.load_balancer_ip_address
  }
}

data "template_file" "api_startup_script" {
  template = file("${path.module}/scripts/backend-startup.sh")

}