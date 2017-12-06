provider "docker" {}

# All containers will be under the same Docker network.
resource "docker_network" "swarm" {
  name = "${var.docker_network_name}"
}

# Bootnode container runs a bootnode for other nodes.
resource "docker_container" "bootnode" {
  name = "${var.docker_containers_prefix}bootnode"

  image    = "${var.image}"
  networks = ["${docker_network.swarm.name}"]

  command = [
    "run-bootnode",
    "--addr=:30301",
    "--verbosity=${var.verbosity}",
  ]

  env = [
    "BOOTNODE_KEY=${var.bootnode_key}",
  ]

  volumes {
    host_path      = "${path.cwd}/data/${var.docker_containers_prefix}bootnode"
    container_path = "/data"
  }

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  # ports {
  #   internal = 30301
  #   external = 30301
  # }
}

# Geth container runs one contianer with geth process.
resource "docker_container" "geth" {
  name = "${var.docker_containers_prefix}geth"

  image    = "${var.image}"
  networks = ["${docker_network.swarm.name}"]

  command = [
    "run-geth",
    "--bootnodes=enode://${var.bootnode_public_key}@${docker_container.bootnode.ip_address}:30301",
    "--verbosity=${var.verbosity}",
    "--networkid=${var.networkid}",
    "--rpc",
    "--rpcaddr=0.0.0.0",
    "--rpcapi=eth,net,web3,txpool",
  ]

  volumes {
    host_path      = "${path.cwd}/data/${var.docker_containers_prefix}geth"
    container_path = "/data"
  }

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  # ports {
  #   internal = 8545
  #   external = 8545
  # }

  # ports {
  #   internal = 30303
  #   external = 30303
  # }

  # ports {
  #   internal = 30303
  #   external = 30303
  #   protocol = "udp"
  # }
}

# A number of swarm instances all in its own container within the same Docker network.
# Each contianer will expose swarm http api on port 8500+n.
resource "docker_container" "swarm" {
  count = "${var.swarm_count}"

  name = "${var.docker_containers_prefix}swarm${count.index + 1}"

  image    = "${var.image}"
  networks = ["${docker_network.swarm.name}"]

  command = [
    "run-swarm",
    "--ens-api=http://${docker_container.geth.name}:8545",
    "--verbosity=${var.verbosity}",
    "--bzznetworkid=${var.networkid}",
    "--bootnodes=enode://${var.bootnode_public_key}@${docker_container.bootnode.ip_address}:30301",
    "--identity=swarm${count.index + 1}",
    "--corsdomain=*",
    "--httpaddr=0.0.0.0",
    "--nat=any",
  ]

  volumes {
    host_path      = "${path.cwd}/data/${var.docker_containers_prefix}swarm${count.index + 1}"
    container_path = "/data"
  }

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  ports {
    internal = 8500
    external = "${count.index+8501}"
  }

  # ports {
  #   internal = 30399
  #   external = "${30501+count.index}"
  # }
}
