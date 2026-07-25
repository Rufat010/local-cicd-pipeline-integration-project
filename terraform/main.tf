terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# The image is built by Jenkins (docker build) before `terraform apply` runs.
# This data source just looks it up locally instead of rebuilding it.
data "docker_image" "app" {
  name = var.app_image
}

resource "docker_container" "app" {
  name  = var.container_name
  image = data.docker_image.app.id

  ports {
    internal = 5000
    external = var.external_port
  }
}
