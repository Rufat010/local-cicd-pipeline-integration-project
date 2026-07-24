variable "app_image" {
  description = "Tag of the Docker image (built by Jenkins) to deploy"
  type        = string
}

variable "container_name" {
  description = "Name for the deployed application container"
  type        = string
  default     = "local-cicd-app"
}

variable "external_port" {
  description = "Host port the application is exposed on"
  type        = number
  default     = 5001
}
