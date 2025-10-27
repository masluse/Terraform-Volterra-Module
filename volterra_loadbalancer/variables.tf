variable "value" {
  description = "The configuration values for the Volterra resources."
  type = object({
    tenant         = string
    namespace      = optional(string)
    site_name      = optional(string)
    site_namespace = optional(string)

    # Origin Pool
    origin_pool = optional(map(object({
      endpoint_selection     = optional(string)
      loadbalancer_algorithm = optional(string)

      os_pn_ip             = optional(string)
      os_pn_inside_network = optional(bool)
      os_pn_name           = optional(string)

      port   = optional(number)
      no_tls = optional(bool)

      use_tls = optional(object({
        tls_config = optional(string, "default_security")
        trusted_ca = optional(list(string), [])
        }),
        {
          tls_config = "default_security"
          trusted_ca = []
      })
    })))

    # App Firewall
    app_firewall = optional(object({
      blocking                                   = optional(bool)
      ds_enable_suppression                      = optional(bool)
      ds_sss_default_attack_type_settings        = optional(bool)
      ds_sss_high_medium_low_accuracy_signatures = optional(bool)
      ds_snaus_staging_period                    = optional(number)
      ds_enable_threat_campaigns                 = optional(bool)
      ds_default_violation_settings              = optional(bool)

      allow_all_response_codes  = optional(bool)
      default_anonymization     = optional(bool)
      use_default_blocking_page = optional(bool)
    }))

    # Load Balancer
    loadbalancer = optional(object({
      domains        = optional(list(string))
      https_port     = optional(number)
      public_ip_name = optional(string, null)

      trusted_clients = optional(map(object({
        actions     = optional(list(string))
        ip_prefix   = optional(string)
        description = optional(string)
      })))

      enable_ip_threat_category = optional(list(string), [])

      trusted_clients_internal = optional(bool, false)
      trusted_clients = optional(map(object({
        actions = optional(list(string), local.actions)
      })), {})

      jwt_validation = optional(object({ cleartext = string, issuer = optional(string, "") }), { cleartext = "" })

      disable_api_definition           = optional(bool)
      disable_api_discovery            = optional(bool)
      no_challenge                     = optional(bool)
      round_robin                      = optional(bool)
      disable_malicious_user_detection = optional(bool)
      disable_rate_limit               = optional(bool)
      no_service_policies              = optional(bool)
      active_service_policies          = optional(map(object({})), {})

      disable_trust_client_ip_headers = optional(bool)
      user_id_client_ip               = optional(bool)

      default_sensitive_data_policy = optional(bool, true)
      disable_api_testing           = optional(bool, true)
      disable_malware_protection    = optional(bool, true)
      disable_threat_mesh           = optional(bool, true)

      www_redirect = optional(list(string))
      custom_route = optional(list(string))
      simple_routes = optional(map(object({
        origin_pool    = optional(string)
        http_method    = optional(string)
        prefix         = optional(string, null)
        path           = optional(string, null)
        host           = optional(string)
        service_policy = optional(bool, false)
        ip_prefixes    = optional(list(string), ["193.200.144.0/24", "195.245.237.0/24", "91.107.224.192/32"])

        disable_host_rewrite   = optional(bool, false)
        request_headers_to_add = optional(map(string), {})
      })))
    }))
  })
}

variable "key" {
  type        = string
  description = "The key for the Volterra resources."
}

variable "tenant" {
  type        = string
  description = "The tenant for which the Volterra resources are being configured."
}

variable "platform" {
  type        = string
  description = "Platform for which the Volterra resources are being configured, e.g., GCP, AZURE, MULTI."
}
