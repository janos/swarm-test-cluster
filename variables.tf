variable "image" {
  description = "Docker image with swarm, geth and bootnode. Tag is required."
  default     = "go-ethereum-swarm-test:latest"
}

variable "verbosity" {
  description = "Verbosity level for swarm, geth and bootnode."
  default     = "4"
}

variable "swarm_count" {
  description = "Number of swarm containers."
  default     = "3"
}

variable "networkid" {
  description = "Network identifier for geth and swarm."
  default     = "321"
}

variable "docker_network_name" {
  description = "Docker network name."
  default     = "swarm"
}

variable "docker_containers_prefix" {
  description = "Optional prefix for namespacing all Docker containers."
  default     = ""
}

variable "bootnode_key" {
  description = "Secret key for bootnode."
  default     = "32078f313bea771848db70745225c52c00981589ad6b5b49163f0f5ee852617d"
}

variable "bootnode_public_key" {
  description = "Public key for bootnode."
  default     = "760c4460e5336ac9bbd87952a3c7ec4363fc0a97bd31c86430806e287b437fd1b01abc6e1db640cf3106b520344af1d58b00b57823db3e1407cbc433e1b6d04d"
}
