# Kibana dashboards with Terraform (local)

Manage a Kibana dashboard as code against a locally running Kibana, using the
[`elastic/elasticstack`](https://registry.terraform.io/providers/elastic/elasticstack/latest)
Terraform provider and its
[`elasticstack_kibana_dashboard`](https://github.com/elastic/terraform-provider-elasticstack/blob/main/docs/resources/kibana_dashboard.md)
resource.

The example in `main.tf` is the web server logs dashboard from the provider's
[getting started guide](https://github.com/elastic/terraform-provider-elasticstack/blob/main/docs/guides/kibana-dashboard-getting-started.md):
a markdown header, two metric panels, a line chart, a horizontal bar chart and a donut chart,
all defined by value on top of the Kibana sample web logs.

Tested with Terraform 1.17.1, provider 0.16.6 and Kibana / Elasticsearch 9.7.0-SNAPSHOT.

## Files

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and provider version pins, provider block |
| `main.tf` | The dashboard resource |
| `outputs.tf` | Dashboard ID output |
| `.envrc.example` | Kibana connection settings (copy to `.envrc`, which is git-ignored) |
| `.terraform.lock.hcl` | Locked provider version; keep it committed |

## Prerequisites

- Kibana 9.4 or later (the public `/api/dashboards` API is stable since 9.5).
- Provider 0.16.6 or later (the guide's `query.expression` attribute was introduced there).

### 1. Install Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

### 2. Run Elasticsearch and Kibana locally

From a Kibana source checkout:

```bash
yarn es snapshot --license trial   # terminal A, Elasticsearch on :9200
yarn start                         # terminal B, Kibana on :5601
```

Local dev credentials are `elastic` / `changeme`.

`yarn start` serves Kibana under a base path (for example `/kibana`). Find it with:

```bash
curl -s -o /dev/null -w "%{redirect_url}\n" http://localhost:5601/api/status
```

Either include the base path in `KIBANA_ENDPOINT` (the default in `.envrc.example`), or start
Kibana with `yarn start --no-base-path` and use `http://localhost:5601`.

Check that the Dashboards API answers:

```bash
curl -u elastic:changeme "http://localhost:5601/kibana/api/dashboards" \
  -H 'elastic-api-version: 2023-10-31'
```

### 3. Install the sample web logs

In Kibana go to **Home → Sample data → Sample web logs → Add data**. This creates the
`kibana_sample_data_logs` data the dashboard queries.

## Usage

```bash
cp .envrc.example .envrc   # adjust endpoint / credentials if needed
source .envrc

terraform init             # downloads the provider
terraform plan
terraform apply
```

Open the dashboard at
`$KIBANA_ENDPOINT/app/dashboards#/view/tf-getting-started-web-logs`.

A second `terraform plan` should report `No changes`.

### Day-to-day workflow

- **Change the dashboard**: edit `main.tf`, then `terraform plan` and `terraform apply`.
  Edits made in the Kibana UI show up as drift on the next `plan` and are reverted by `apply`.
- **Add a panel**: append an entry to `panels`. The layout grid is 48 columns wide; place panels with
  `grid = { x, y, w, h }` so they do not overlap.
- **New Lens charts**: build the chart in the Kibana UI, inspect its panel JSON, and translate it
  into a `vis_config.by_value` block (see the guide's "How to get Lens visualization JSON").
- **Stable ID**: `dashboard_id` gives the dashboard a fixed, readable ID. Changing it recreates the dashboard.
- **Other spaces**: set `space_id` on the resource.
- **Clean up**: `terraform destroy`.

## Troubleshooting

- **404 / HTML responses or redirects**: the endpoint is missing Kibana's base path. Fix
  `KIBANA_ENDPOINT` or restart Kibana with `--no-base-path`.
- **401**: wrong credentials in `.envrc`, or the file was not sourced in the current shell.
- **Empty panels**: the sample web logs are not installed, or the time range does not cover them.
- **"Provider produced inconsistent result" or perpetual diffs on Lens panels**: a snapshot Kibana
  can be ahead of what the provider has been tested with. Upgrade the provider
  (`terraform init -upgrade` after bumping the version in `versions.tf`).

## Further reading

- [Dashboard operations guide](https://github.com/elastic/terraform-provider-elasticstack/blob/main/docs/guides/kibana-dashboard-operations.md):
  controls, KPI rows, area and table panels, Discover sessions.
- [Advanced dashboards guide](https://github.com/elastic/terraform-provider-elasticstack/blob/main/docs/guides/kibana-dashboard-advanced.md):
  sections, image panels, gauges, heatmaps, ES|QL controls, access control, tags.
- [Provider authentication options](https://github.com/elastic/terraform-provider-elasticstack/blob/main/docs/index.md).
