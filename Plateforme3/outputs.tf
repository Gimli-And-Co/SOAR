/*
output "service_url" {
  value = google_cloud_run_service.run_service_front.status[0].url
}*/


output "url" {
  value = "http://${module.lb-http.external_ip}"
}

/*output "db_ip" {
  value = google_sql_database_instance.master.
}*/