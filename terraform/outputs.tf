output "container_id" {
  value = docker_container.app.id
}

output "app_url" {
  value = "http://localhost:${var.external_port}"
}
