output "dashboard_id" {
  description = "Kibana dashboard ID. Open it at <KIBANA_ENDPOINT>/app/dashboards#/view/<dashboard_id>."
  value       = elasticstack_kibana_dashboard.web_logs.dashboard_id
}
