
resource "null_resource" "after-web" {
  depends_on = [google_compute_instance.web]
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${google_compute_instance.web.network_interface.0.access_config.0.nat_ip},${google_compute_instance.web2.network_interface.0.access_config.0.nat_ip}' --private-key ${var.private_key_path} --user ${var.ssh_user} ./ansible/web.yml -e BACKEND_URL=http://${google_compute_forwarding_rule.api.ip_address}/"
  }
}

resource "null_resource" "after-api" {
  depends_on = [google_compute_instance.api, google_compute_instance.api2]
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${join(",", google_compute_instance.api.*.network_interface.0.access_config.0.nat_ip)},${join(",", google_compute_instance.api2.*.network_interface.0.access_config.0.nat_ip)}' --private-key ${var.private_key_path} --user ${var.ssh_user} ./ansible/api.yml -e DB_HOST=${google_compute_forwarding_rule.db.ip_address}"
  }
}

resource "null_resource" "after-db" {
  depends_on = [google_compute_instance.db]
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${join(",", google_compute_instance.db.*.network_interface.0.access_config.0.nat_ip)}' --private-key ${var.private_key_path} --user ${var.ssh_user} ./ansible/db_psql.yml"
  }
}