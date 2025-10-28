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
| <a name="input_value"></a> [value](#input\_value) | The configuration values for the Volterra resources. | <pre>object({<br/>    tenant         = string<br/>    namespace      = optional(string)<br/>    site_name      = optional(string)<br/>    site_namespace = optional(string)<br/><br/>    # Origin Pool<br/>    origin_pool = optional(map(object({<br/>      endpoint_selection     = optional(string)<br/>      loadbalancer_algorithm = optional(string)<br/><br/>      os_pn_ip             = optional(string)<br/>      os_pn_inside_network = optional(bool)<br/>      os_pn_name           = optional(string)<br/><br/>      port   = optional(number)<br/>      no_tls = optional(bool)<br/><br/>      use_tls = optional(object({<br/>        tls_config = optional(string, "default_security")<br/>        trusted_ca = optional(list(string), [])<br/>        }),<br/>        {<br/>          tls_config = "default_security"<br/>          trusted_ca = []<br/>      })<br/>    })))<br/><br/>    # App Firewall<br/>    app_firewall = optional(object({<br/>      blocking                                   = optional(bool)<br/>      ds_enable_suppression                      = optional(bool)<br/>      ds_sss_default_attack_type_settings        = optional(bool)<br/>      ds_sss_high_medium_low_accuracy_signatures = optional(bool)<br/>      ds_snaus_staging_period                    = optional(number)<br/>      ds_enable_threat_campaigns                 = optional(bool)<br/>      ds_default_violation_settings              = optional(bool)<br/><br/>      allow_all_response_codes  = optional(bool)<br/>      default_anonymization     = optional(bool)<br/>      use_default_blocking_page = optional(bool)<br/>    }))<br/><br/>    # Load Balancer<br/>    loadbalancer = optional(object({<br/>      domains        = optional(list(string))<br/>      https_port     = optional(number)<br/>      public_ip_name = optional(string, null)<br/><br/>      enable_ip_threat_category = optional(list(string), [])<br/><br/>      trusted_clients_internal = optional(bool, false)<br/>      trusted_clients = optional(map(object({<br/>        actions = optional(list(string), ["TAKE_FROM_LOCALS"])<br/>      })), {})<br/><br/>      jwt_validation = optional(object({ cleartext = string, issuer = optional(string, "") }), { cleartext = "" })<br/><br/>      disable_api_definition           = optional(bool)<br/>      disable_api_discovery            = optional(bool)<br/>      no_challenge                     = optional(bool)<br/>      round_robin                      = optional(bool)<br/>      disable_malicious_user_detection = optional(bool)<br/>      disable_rate_limit               = optional(bool)<br/>      no_service_policies              = optional(bool)<br/>      active_service_policies          = optional(map(object({})), {})<br/><br/>      disable_trust_client_ip_headers = optional(bool)<br/>      user_id_client_ip               = optional(bool)<br/><br/>      default_sensitive_data_policy = optional(bool, true)<br/>      disable_api_testing           = optional(bool, true)<br/>      disable_malware_protection    = optional(bool, true)<br/>      disable_threat_mesh           = optional(bool, true)<br/><br/>      www_redirect = optional(list(string))<br/>      custom_route = optional(list(string))<br/>      simple_routes = optional(map(object({<br/>        origin_pool    = optional(string)<br/>        http_method    = optional(string)<br/>        prefix         = optional(string, null)<br/>        path           = optional(string, null)<br/>        host           = optional(string)<br/>        service_policy = optional(bool, false)<br/>        ip_prefixes    = optional(list(string), ["TAKE_FROM_LOCALS"])<br/><br/>        disable_host_rewrite   = optional(bool, false)<br/>        request_headers_to_add = optional(map(string), {})<br/>      })))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->