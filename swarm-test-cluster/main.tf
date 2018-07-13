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
    "/run-bootnode.sh",
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
    "/run-geth.sh",
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
    "/run-swarm.sh",
    "--ens-api=http://${docker_container.geth.name}:8545",
    "--verbosity=${var.verbosity}",
    "--bzznetworkid=${var.networkid}",
    "--bootnodes=enode://${var.bootnode_public_key}@${docker_container.bootnode.ip_address}:30301",
    "--identity=swarm${count.index + 1}",
    "--corsdomain=*",
    "--httpaddr=0.0.0.0",
    "--nat=any",
    "--pprof",
    "--pprofaddr=0.0.0.0",
    "--ws",
    "--tracing",
    "--tracing.endpoint=jaeger:6831",
    "--tracing.svc=swarm${count.index+1}",
    "--metrics",
    "--metrics.influxdb.export",
    "--metrics.influxdb.username=test",
    "--metrics.influxdb.password=test",
    "--metrics.influxdb.endpoint=http://stateth_influxdb:8086",
    "--metrics.influxdb.host.tag=swarm${count.index + 1}",
    "--wsaddr=0.0.0.0",
    "--wsorigins=*"
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

  ports {
    internal = 6060
    external = "${count.index+6061}"
  }

  ports {
    internal = 8546
    external = "${count.index+8601}"
  }

  # ports {
  #   internal = 30399
  #   external = "${30501+count.index}"
  # }
}

resource "docker_container" "jaeger" {
  name = "jaeger"

  image    = "jaegertracing/all-in-one:latest"
  networks = ["${docker_network.swarm.name}"]

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  ports {
    internal = 6831
    external = 6831
  }

  ports {
    internal = 16686
    external = 16686
  }
}

resource "docker_container" "stateth" {
  name = "stateth"

  image    = "nonsens3/stateth"
  networks = ["${docker_network.swarm.name}"]

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  destroy_grace_seconds = 30

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "${path.cwd}/grafana_dashboards"
    container_path = "/grafana_dashboards"
  }

  command = [
    "/stateth",
    "--rm",
    "--docker-network=swarm",
    "--influxdb-database=metrics",
    "--grafana-dashboards-folder=/grafana_dashboards"
  ]
}
