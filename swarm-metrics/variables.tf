variable "docker_network_name" {
  description = "Docker network name."
  default     = "metrics"
}

variable "docker_containers_prefix" {
  description = "Optional prefix for namespacing all Docker containers."
  default     = "terra_"
}
