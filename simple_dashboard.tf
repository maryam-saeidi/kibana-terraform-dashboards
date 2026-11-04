import {
  to = elasticstack_kibana_dashboard.simple
  id = "mary/25f89bc3-56d7-4fa9-ab0a-a706d5ca9727"
}

resource "elasticstack_kibana_dashboard" "simple" {
  space_id     = "mary"
  dashboard_id = "25f89bc3-56d7-4fa9-ab0a-a706d5ca9727"
  title        = "[Mary] Simple dashboard managed by Terraform"
  description  = "A simple dashboard managed by Terraform using the Kibana sample logs data."

  access_control = {
    access_mode = "default"
  }
  options = {
    auto_apply_filters = true
    hide_panel_titles  = false
    hide_panel_borders = false
    use_margins        = true
    sync_colors        = false
    sync_tooltips      = false
    sync_cursor        = true
  }

  query = {
    language   = "kql"
    expression = ""
  }

  panels = [
    {
      type = "vis"
      grid = { x = 0, y = 0, w = 9, h = 6 }
      vis_config = {
        by_value = {
          metric_chart_config = {
            data_source_json = jsonencode({
              type   = "data_view_reference"
              ref_id = "eefd0044-87b5-4be3-aa5d-2d1697dc7722"
            })
            ignore_global_filters = false
            sampling              = 1
            query                 = { language = "kql", expression = "" }
            metrics = [{
              config_json = jsonencode({
                type          = "primary"
                operation     = "count"
                empty_as_null = true
                color         = { type = "auto" }
              })
            }]
          }
        }
      }
    },
  ]
}
