# Volterra Loadbalancer Module

Creates a Volterra Loadbalancer.

## Usage

To use this module, include it in your Terraform configuration as shown below:

### locals.tf

```hcl
locals {
  loadbalancer = {
    aop-uat = {
      namespace      = "aop"
      tenant         = "bison-group-yybostat"
      site_name      = "vsite-gcp-p"
      site_namespace = "shared"
      origin_pool = {
        endpoint_selection     = "DISTRIBUTED"
        loadbalancer_algorithm = "ROUND_ROBIN"
        os_pn_ip               = "10.168.59.7"
        os_pn_inside_network   = true
        port                   = 80
        no_tls                 = true
      }
      app_firewall = {
        blocking                                   = true
        ds_enable_suppression                      = true
        ds_sss_default_attack_type_settings        = true
        ds_sss_high_medium_low_accuracy_signatures = true
        ds_snaus_staging_period                    = "7"
        ds_enable_threat_campaigns                 = true
        ds_default_violation_settings              = true
        allow_all_response_codes                   = true
        default_anonymization                      = true
        use_default_blocking_page                  = true
      }
      loadbalancer = {
        domains                          = ["uat.aop.nprd.gcp.fenaco.com", "www.uat.aop.nprd.gcp.fenaco.com", "uat-proxy.aop.nprd.gcp.fenaco.com", "uat-mc.aop.nprd.gcp.fenaco.com"]
        http_port                        = 80
        https_port                       = 443
        advertise_on_public_default_vip  = true
        disable_api_definition           = true
        disable_api_discovery            = true
        no_challenge                     = true
        round_robin                      = true
        disable_malicious_user_detection = true
        disable_rate_limit               = true
        no_service_policies              = false
        active_service_policies = {
          sp-default-fenaco   = {}
          sp-pentest-redguard = {}
          sp-gcp-saucelabs    = {}
        }
        trusted_clients = {
          redguard = {
            description = "temporary exception for Redguard tests"
            actions = [
              "SKIP_PROCESSING_API_PROTECTION",
              "SKIP_PROCESSING_BOT",
              "SKIP_PROCESSING_DDOS_PROTECTION",
              "SKIP_PROCESSING_IP_REPUTATION",
              "SKIP_PROCESSING_MUM",
              "SKIP_PROCESSING_MALWARE_PROTECTION",
              "SKIP_PROCESSING_OAS_VALIDATION",
              "SKIP_PROCESSING_THREAT_MESH",
              "SKIP_PROCESSING_WAF"
            ]
            ip_prefix = "159.100.245.54/32"
          }
        }
        www_redirect                    = ["uat.aop.nprd.gcp.fenaco.com"]
        custom_route                    = ["clickops"]
        disable_trust_client_ip_headers = true
        user_id_client_ip               = true
      }
    }
  }
}
```

### modules.tf

```hcl
module "volterra_loadbalancer" {
  source   = "git::https://gitlab.gcp.fenaco.com/templates/terraform-modules/terraform-volterra.git//volterra_loadbalancer?ref=v1.0.1"
  for_each = local.loadbalancer

  # Variables
  key      = each.key
  value    = each.value
  tenant   = local.tenant
  platform = local.platform
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [volterra_app_firewall.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/app_firewall) | resource |
| [volterra_http_loadbalancer.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/http_loadbalancer) | resource |
| [volterra_origin_pool.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/origin_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key"></a> [key](#input\_key) | The key for the Volterra resources. | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | Platform for which the Volterra resources are being configured, e.g., GCP, AZURE, MULTI. | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | The tenant for which the Volterra resources are being configured. | `string` | n/a | yes |
| <a name="input_trusted_clients"></a> [trusted\_clients](#input\_trusted\_clients) | The configuration of the trusted clients | `any` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | The value for the Volterra resources. | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->