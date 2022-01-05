
output "service_url_frontend" {
  value = google_cloud_run_service.frontend.status[0].url
}

output "service_url_backend" {
  value = google_cloud_run_service.backend.status[0].url
}
