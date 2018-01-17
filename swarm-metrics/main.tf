provider "docker" {}

# All containers will be under the same Docker network.
resource "docker_network" "metrics" {
  name = "${var.docker_network_name}"
}

resource "docker_container" "influxdb" {
  name = "${var.docker_containers_prefix}influxdb"

  image    = "influxdb"
  networks = ["${docker_network.metrics.name}"]

  env = [
    "INFLUXDB_DB=metrics",
    "INFLUXDB_ADMIN_USER=admin",
    "INFLUXDB_ADMIN_PASSWORD=admin",
  ]

  ports {
    internal = 8086
    external = 8086
  }

  log_opts {
    max-file = "10"
    max-size = "100M"
  }
}

resource "docker_container" "grafana" {
  name = "${var.docker_containers_prefix}grafana"

  image    = "grafana/grafana"
  networks = ["${docker_network.metrics.name}"]

  ports {
    internal = 3000
    external = 3000
  }

  log_opts {
    max-file = "10"
    max-size = "100M"
  }

  # Wait for grafana to spin up, so that we can provision data sources and dashboards
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "template_dir" "config" {
  source_dir      = "${path.module}/config_templates"
  destination_dir = "${path.cwd}/config"

  vars {
    influxdb_address = "${docker_container.influxdb.name}"
  }
}
