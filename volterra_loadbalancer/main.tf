resource "volterra_origin_pool" "default" {
  for_each               = var.value.origin_pool
  name                   = "pool-${var.platform}-${var.key}-${each.key}"
  namespace              = "nspace-${var.platform}-${var.value.namespace}"
  endpoint_selection     = each.value.endpoint_selection
  loadbalancer_algorithm = each.value.loadbalancer_algorithm

  origin_servers {
    // One of the arguments from this list "consul_service custom_endpoint_object k8s_service private_ip private_name public_ip public_name vn_private_ip vn_private_name" must be set

    dynamic "private_ip" {
      for_each = each.value.os_pn_ip == "" ? [] : [1]
      content {


        // One of the arguments from this list "ip ipv6" must be set

        ip = each.value.os_pn_ip

        inside_network = each.value.os_pn_inside_network

        site_locator {
          virtual_site {
            name      = var.value.site_name
            namespace = var.value.site_namespace
            tenant    = var.value.tenant
          }
        }
      }
    }

    dynamic "private_name" {
      for_each = each.value.os_pn_name == "" ? [] : [1]
      content {
        dns_name       = each.value.os_pn_name
        inside_network = each.value.os_pn_inside_network
        site_locator {
          virtual_site {
            name      = var.value.site_name
            namespace = var.value.site_namespace
            tenant    = var.value.tenant
          }
        }
      }
    }

    labels = {
    }
  }

  // One of the arguments from this list "automatic_port lb_port port" must be set

  port = each.value.port

  // One of the arguments from this list "no_tls use_tls" must be set

  no_tls = each.value.no_tls
  dynamic "use_tls" {
    for_each = each.value.no_tls ? [] : [1]
    content {
      dynamic "use_server_verification" {
        for_each = try(toset(each.value.use_tls.trusted_ca), {})
        content {
          dynamic "trusted_ca" {
            for_each = toset(each.value.use_tls.trusted_ca)
            content {
              name      = trusted_ca.value
              tenant    = var.value.tenant
              namespace = "nspace-${var.platform}-${var.value.namespace}"
            }
          }
        }
      }
      tls_config {
        default_security = try((each.value.use_tls.tls_config == "default_security" ? true : false), true)
        low_security     = try((each.value.use_tls.tls_config == "low_security" ? true : false), false)
        medium_security  = try((each.value.use_tls.tls_config == "medium_security" ? true : false), false)
      }
      default_session_key_caching = true
      no_mtls                     = true
      use_host_header_as_sni      = true
    }
  }
}


resource "volterra_app_firewall" "default" {
  name      = "waf-${var.platform}-${var.key}"
  namespace = "nspace-${var.platform}-${var.value.namespace}"

  #labels = {
  #  label-name = "value"
  #}

  // One of the arguments from this list "blocking monitoring use_loadbalancer_setting" must be set

  #use_loadbalancer_setting = true
  #monitoring = true
  blocking = var.value.app_firewall.blocking

  // One of the arguments from this list "ai_risk_based_blocking default_detection_settings detection_settings" must be set

  // Security Policy Settings

  detection_settings {
    // One of the arguments from this list "disable_suppression enable_suppression" must be set

    enable_suppression = var.value.app_firewall.ds_enable_suppression

    signature_selection_setting {
      // One of the arguments from this list "attack_type_settings default_attack_type_settings" must be set

      default_attack_type_settings = var.value.app_firewall.ds_sss_default_attack_type_settings

      // One of the arguments from this list "high_medium_accuracy_signatures high_medium_low_accuracy_signatures only_high_accuracy_signatures" must be set

      high_medium_low_accuracy_signatures = var.value.app_firewall.ds_sss_high_medium_low_accuracy_signatures
    }

    // One of the arguments from this list "disable_staging stage_new_and_updated_signatures stage_new_signatures" can be set

    stage_new_and_updated_signatures {
      staging_period = var.value.app_firewall.ds_snaus_staging_period
    }

    // One of the arguments from this list "disable_threat_campaigns enable_threat_campaigns" must be set

    enable_threat_campaigns = var.value.app_firewall.ds_enable_threat_campaigns

    // One of the arguments from this list "default_violation_settings violation_settings" must be set

    default_violation_settings = var.value.app_firewall.ds_default_violation_settings
  }

  // Bot Protection Settings

  // One of the arguments from this list "bot_protection_setting default_bot_setting" must be set

  // Advanced Configuration

  // One of the arguments from this list "allow_all_response_codes allowed_response_codes" must be set

  allow_all_response_codes = var.value.app_firewall.allow_all_response_codes

  // One of the arguments from this list "custom_anonymization default_anonymization disable_anonymization" must be set

  default_anonymization = var.value.app_firewall.default_anonymization

  // One of the arguments from this list "blocking_page use_default_blocking_page" must be set

  use_default_blocking_page = var.value.app_firewall.use_default_blocking_page

}


resource "volterra_http_loadbalancer" "default" {
  name      = "lb-${var.platform}-${var.key}"
  namespace = "nspace-${var.platform}-${var.value.namespace}"
  disable   = false

  domains = var.value.loadbalancer.domains

  // One of the arguments from this list "http https https_auto_cert" must be set

  https_auto_cert {
    add_hsts = true

    http_redirect         = true
    enable_path_normalize = true
    no_mtls               = true

    // One of the arguments from this list "port port_ranges" must be set

    port = var.value.loadbalancer.https_port
  }

  l7_ddos_protection {
    ddos_policy_none = true
    mitigation_block = true
  }


  // One of the arguments from this list "advertise_custom advertise_on_public advertise_on_public_default_vip do_not_advertise" must be set

  advertise_on_public_default_vip = var.value.loadbalancer.advertise_on_public_default_vip

  // Origin Pool configuration
  default_route_pools {
    pool {
      tenant    = var.value.tenant
      name      = "pool-${var.platform}-${var.key}-default"
      namespace = "nspace-${var.platform}-${var.value.namespace}"
    }
    weight   = 0
    priority = 1
  }

  // One of the arguments from this list "app_firewall disable_waf" must be set

  app_firewall {
    tenant    = var.value.tenant
    name      = "waf-${var.platform}-${var.key}"
    namespace = "nspace-${var.platform}-${var.value.namespace}"
  }

  dynamic "trusted_clients" {
    for_each = var.value.loadbalancer.trusted_clients
    content {
      actions   = trusted_clients.value.actions
      ip_prefix = trusted_clients.value.ip_prefix
      metadata {
        name        = "tc-${var.platform}-${trusted_clients.key}"
        description = trusted_clients.value.description
      }
    }
  }

  dynamic "enable_ip_reputation" {
    for_each = try(var.value.loadbalancer.enable_ip_threat_category == [] ? [] : [1], [])
    content {
      ip_threat_categories = var.value.loadbalancer.enable_ip_threat_category
    }
  }

  // One of the arguments from this list "api_definition api_definitions api_specification disable_api_definition" must be set

  disable_api_definition = var.value.loadbalancer.disable_api_definition

  // One of the arguments from this list "disable_api_discovery enable_api_discovery" must be set

  disable_api_discovery = var.value.loadbalancer.disable_api_discovery

  // One of the arguments from this list "captcha_challenge enable_challenge js_challenge no_challenge policy_based_challenge" must be set

  no_challenge = var.value.loadbalancer.no_challenge

  // One of the arguments from this list "cookie_stickiness least_active random ring_hash round_robin source_ip_stickiness" must be set

  round_robin = var.value.loadbalancer.round_robin

  // One of the arguments from this list "disable_malicious_user_detection enable_malicious_user_detection" must be set

  disable_malicious_user_detection = var.value.loadbalancer.disable_malicious_user_detection

  // One of the arguments from this list "api_rate_limit disable_rate_limit rate_limit" must be set

  disable_rate_limit = var.value.loadbalancer.disable_rate_limit

  // One of the arguments from this list "active_service_policies no_service_policies service_policies_from_namespace" must be set

  no_service_policies = var.value.loadbalancer.no_service_policies

  dynamic "active_service_policies" {
    # nur erzeugen, wenn KEIN no_service_policies aktiv ist
    for_each = var.value.loadbalancer.no_service_policies ? [] : [1]
    content {
      dynamic "policies" {
        for_each = try(var.value.loadbalancer.active_service_policies, {})
        content {
          name      = policies.key
          namespace = "nspace-${var.platform}-${var.value.namespace}"
          tenant    = var.value.tenant
        }
      }
    }
  }

  // One of the arguments from this list "disable_trust_client_ip_headers enable_trust_client_ip_headers" must be set

  disable_trust_client_ip_headers = var.value.loadbalancer.disable_trust_client_ip_headers

  // One of the arguments from this list "user_id_client_ip user_identification" must be set

  user_id_client_ip = var.value.loadbalancer.user_id_client_ip

  default_sensitive_data_policy = try(var.value.loadbalancer.default_sensitive_data_policy, true)
  disable_api_testing           = try(var.value.loadbalancer.disable_api_testing, true)
  disable_malware_protection    = try(var.value.loadbalancer.disable_malware_protection, true)
  disable_threat_mesh           = try(var.value.loadbalancer.disable_threat_mesh, true)

  dynamic "routes" {
    for_each = toset(var.value.loadbalancer.www_redirect)
    content {
      redirect_route {
        http_method = "ANY"
        path {
          prefix = "/"
        }
        route_redirect {
          proto_redirect = "incoming-proto"
          host_redirect  = routes.key
          response_code  = 301
        }
        headers {
          exact = "www.${routes.key}"
          name  = "host"
        }
      }
    }
  }

  dynamic "routes" {
    for_each = toset(var.value.loadbalancer.custom_route)
    content {
      custom_route_object {
        route_ref {
          name      = "routes-${var.value.namespace}-${routes.key}"
          namespace = "nspace-${var.platform}-${var.value.namespace}"
          tenant    = var.value.tenant
        }
      }
    }
  }

  dynamic "routes" {
    for_each = var.value.loadbalancer.simple_routes
    content {
      simple_route {
        origin_pools {
          pool {
            tenant    = var.value.tenant
            name      = "pool-${var.platform}-${var.key}-${routes.value.origin_pool}"
            namespace = "nspace-${var.platform}-${var.value.namespace}"
          }
        }
        http_method = routes.value.http_method
        path {
          prefix = try(routes.value.prefix, null)
          path   = try(routes.value.path, null)
        }
        auto_host_rewrite    = try(routes.value.disable_host_rewrite == true ? false : true, true)
        disable_host_rewrite = try(routes.value.disable_host_rewrite, false)
        headers {
          exact = routes.value.host
          name  = "host"
        }
        advanced_options {
          dynamic "request_headers_to_add" {
            for_each = try(routes.value.request_headers_to_add, {})
            content {
              append = false
              name   = request_headers_to_add.key
              value  = request_headers_to_add.value
            }
          }
          common_buffering                           = try(routes.value.request_headers_to_add == {} ? null : true, null)
          common_hash_policy                         = try(routes.value.request_headers_to_add == {} ? null : true, null)
          default_retry_policy                       = try(routes.value.request_headers_to_add == {} ? null : true, null)
          disable_mirroring                          = try(routes.value.request_headers_to_add == {} ? null : true, null)
          disable_prefix_rewrite                     = try(routes.value.request_headers_to_add == {} ? null : true, null)
          disable_spdy                               = try(routes.value.request_headers_to_add == {} ? null : true, null)
          disable_web_socket_config                  = try(routes.value.request_headers_to_add == {} ? null : true, null)
          priority                                   = try(routes.value.request_headers_to_add == {} ? null : "DEFAULT", null)
          retract_cluster                            = try(routes.value.request_headers_to_add == {} ? null : true, null)
        }
      }
    }
  }

  routes {
    direct_response_route {
      http_method = "ANY"
      path {
        prefix = "/"
      }
      route_direct_response {
        response_code = 403
        response_body = "Forbidden"
      }
    }
  }

  depends_on = [volterra_app_firewall.default, volterra_origin_pool.default]
}
