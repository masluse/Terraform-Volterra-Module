resource "volterra_route" "default" {
  count     = var.ignore_route_changes == false ? 1 : 0
  name      = "routes-${var.namespace}-${var.key}"
  namespace = "nspace-${var.platform}-${var.namespace}"

  dynamic "routes" {
    for_each = var.path_redirects
    content {
      match {
        http_method = "ANY"
        path {
          path = routes.key
        }
      }
      route_redirect {
        path_redirect  = routes.value
        response_code  = 301
        proto_redirect = "incoming-proto"
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
      match {
        http_method = "ANY"
        path {
          path = routes.key
        }
      }
      route_redirect {
        path_redirect  = routes.value
        response_code  = 301
        proto_redirect = "incoming-proto"
      }
    }
  }

  lifecycle {
    ignore_changes = [routes]
  }
}