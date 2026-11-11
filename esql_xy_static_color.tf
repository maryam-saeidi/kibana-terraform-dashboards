# Reproduces https://github.com/elastic/kibana/issues/291451
# Kibana accepts the static Y-metric color below but stores {"type":"auto"} instead,
# so `terraform apply` fails with "Provider produced inconsistent result after apply".
resource "elasticstack_kibana_dashboard" "esql_xy_static_color" {
  dashboard_id = "tf-repro-291451"
  title        = "Repro: ES|QL XY static Y color"
  description  = "Reproduces elastic/kibana#291451 using the Kibana sample logs data."

  time_range = {
    from = "now-7d"
    to   = "now"
  }

  refresh_interval = {
    pause = true
    value = 0
  }

  query = {
    language   = "kql"
    expression = ""
  }

  panels = [
    {
      type = "vis"
      grid = { x = 0, y = 0, w = 48, h = 14 }
      vis_config = {
        by_value = {
          xy_chart_config = {
            title = "Bytes over time (ES|QL)"
            axis = {
              y = { domain_json = jsonencode({ type = "fit" }) }
            }
            decorations = {}
            fitting     = { type = "none" }
            legend      = {}
            layers = [{
              type = "line"
              data_layer = {
                data_source_json = jsonencode({
                  type  = "esql"
                  query = "FROM kibana_sample_data_logs | KEEP @timestamp, host.keyword, bytes | LIMIT 10"
                })
                x_json = jsonencode({ column = "@timestamp" })
                breakdown_by_json = jsonencode({
                  column = "host.keyword"
                  color = {
                    mode    = "categorical"
                    palette = "default"
                    mapping = [{
                      values = ["www.elastic.co"]
                      color  = { type = "color_code", value = "#E7664C" }
                    }]
                    unassigned = { type = "color_code", value = "#D3DAE6" }
                  }
                })
                y = [{
                  config_json = jsonencode({
                    column = "bytes"
                    format = { type = "number" }
                    color  = { type = "static", color = "#54B399" }
                  })
                }]
              }
            }]
          }
        }
      }
    },
  ]
}
