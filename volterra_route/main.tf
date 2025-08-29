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
            path = replace(replace(replace(replace(replace(match.value.path, " ", "%20"), "ä", "%C3%A4"), "ö", "%C3%B6"), "ü", "%C3%BC"), "é", "%C3%A9")
          }
          dynamic "query_params" {
            for_each = match.value.query_params
            content {
              key   = query_params.key
              exact = replace(replace(replace(replace(replace(query_params.value, " ", "%20"), "ä", "%C3%A4"), "ö", "%C3%B6"), "ü", "%C3%BC"), "é", "%C3%A9")
            }
          }
          dynamic "headers" {
            for_each = match.value.headers
            content {
              name  = headers.key
              exact = headers.value
            }
          }
        }
      }
      route_redirect {
        path_redirect  = routes.value.path_redirect
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
        for_each = replace(replace(replace(replace(replace(match.value.path, " ", "%20"), "ä", "%C3%A4"), "ö", "%C3%B6"), "ü", "%C3%BC"), "é", "%C3%A9")
        content {
          http_method = "ANY"
          path {
            path = match.value.path
          }
          dynamic "query_params" {
            for_each = match.value.query_params
            content {
              key   = query_params.key
              exact = replace(replace(replace(replace(replace(query_params.value, " ", "%20"), "ä", "%C3%A4"), "ö", "%C3%B6"), "ü", "%C3%BC"), "é", "%C3%A9")
            }
          }
          dynamic "headers" {
            for_each = match.value.headers
            content {
              name  = headers.key
              exact = headers.value
            }
          }
        }
      }
      route_redirect {
        path_redirect  = routes.value.path_redirect
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