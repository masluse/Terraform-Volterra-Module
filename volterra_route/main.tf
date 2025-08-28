resource "volterra_route" "default" {
  count     = var.ignore_route_changes == false ? 1 : 0
  name      = "routes-${var.namespace}-${var.key}"
  namespace = "nspace-${var.platform}-${var.namespace}"

  dynamic "routes" {
    for_each = var.path_redirects
    content {
      dynamic "match" {
        for_each = routes.value.match
        content {
          http_method = "ANY"
          path {
            path = match.value.path
          }
          dynamic "query_params" {
            for_each = match.value.query_params
            content {
              key   = query_params.value
              exact = query_params.key
            }
          }
        }
      }
      route_redirect {
        path_redirect  = routes.key
        response_code  = 301
        proto_redirect = "incoming-proto"
        remove_all_params = routes.value.params == "remove" ? true : false
      }
    }
  }
}

resource "volterra_route" "ignore_route_changes" {
  count     = var.ignore_route_changes == true ? 1 : 0
  name      = "routes-${var.namespace}-${var.key}"
  namespace = "nspace-${var.platform}-${var.namespace}"

  dynamic "routes" {
    for_each = var.path_redirects
    content {
      dynamic "match" {
        for_each = routes.value.match
        content {
          http_method = "ANY"
          path {
            path = match.value.path
          }
          dynamic "query_params" {
            for_each = match.value.query_params
            content {
              key   = query_params.value
              exact = query_params.key
            }
          }
        }
      }
      route_redirect {
        path_redirect  = routes.key
        response_code  = 301
        proto_redirect = "incoming-proto"
        remove_all_params = routes.value.params == "remove" ? true : false
      }
    }
  }

  lifecycle {
    ignore_changes = [routes]
  }
}