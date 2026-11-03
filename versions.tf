terraform {
  required_version = ">= 1.0.0"

  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~> 0.16.6"
    }
  }
}

# Connection settings come from KIBANA_ENDPOINT, KIBANA_USERNAME and
# KIBANA_PASSWORD (see .envrc.example).
provider "elasticstack" {
  kibana {}
}
