provider "grafana" {
  url  = "http://localhost:3000/"
  auth = "admin:admin"
}

resource "grafana_data_source" "influxdb_metrics" {
  type          = "influxdb"
  name          = "metrics"
  url           = "http://${docker_container.influxdb.name}:8086/"
  username      = "admin"
  password      = "admin"
  database_name = "metrics"

  depends_on = ["docker_container.grafana"]
}

resource "grafana_dashboard" "metrics_eval" {
  config_json = "${file("dashboards/metrics_eval.json")}"
}
