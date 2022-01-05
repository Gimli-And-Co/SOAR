
/*output "service_url" {
  value = google_cloud_run_service.frontend.status[0].url
}*/

output "lb-front-url" {
  value = "http://${module.lb-http-frontend.external_ip}"
}

output "lb-back-url" {
  value = "http://${module.lb-http-backend.external_ip}"
}
