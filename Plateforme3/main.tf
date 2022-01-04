provider "google" {
  project = var.project_id
}

/*
# Open the URL of the webapp
provisioner "local-exec" {
  command = "chrome ${frontend_url}"
}*/

/*
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo $FOO $BAR $BAZ >> ../webapp/soar-backend.env"

    environment = {
      FOO = "bar"
      BAR = 1
      BAZ = "true"
    }
  }
}
*/
/*resource "localhost" "localhost" {
provisioner "local-exec" {
command = "export DB_IP=${db_ip}"
}
}*/