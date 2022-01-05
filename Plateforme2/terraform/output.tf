output "web_lb" {
  value = google_compute_forwarding_rule.web.ip_address
}

output "api_lb" {
  value = google_compute_forwarding_rule.api.ip_address
}

output "db_lb" {
  value = google_compute_forwarding_rule.db.ip_address
}

output "web_ips" {
  value = format("%s %s", google_compute_instance.web.network_interface.0.access_config.0.nat_ip, google_compute_instance.web2.network_interface.0.access_config.0.nat_ip)
}

output "api_ips" {
  value = join(" ", concat(google_compute_instance.api.*.network_interface.0.access_config.0.nat_ip, google_compute_instance.api2.*.network_interface.0.access_config.0.nat_ip))
}
output "db_ips" {
  value = join(" ", google_compute_instance.db.*.network_interface.0.access_config.0.nat_ip)
}

/* output "nat_ip_address" {
  value = google_compute_address.nat-ip.address
} */