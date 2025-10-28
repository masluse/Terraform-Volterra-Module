resource "volterra_namespace" "default" {
  name = "nspace-${var.platform}-${var.key}"
}

resource "volterra_service_policy" "default" {
  name      = "sp-${var.platform}-default-fenaco"
  namespace = volterra_namespace.default.name
  algo      = "FIRST_MATCH"

  // One of the arguments from this list "deny_list rule_list legacy_rule_list allow_all_requests deny_all_requests internally_generated allow_list" must be set

  allow_list {
    // One of the arguments from this list "default_action_next_policy default_action_deny default_action_allow" must be set
    default_action_next_policy = true

    prefix_list {
      prefixes      = local.onprem_subnets
      ipv6_prefixes = []
    }
  }
  // One of the arguments from this list "any_server server_name server_selector server_name_matcher" must be set
  any_server = true
}