# Volterra Route Module

Creates a Volterra Route.

## Usage

To use this module, include it in your Terraform configuration as shown below:

### locals.tf

```hcl
locals {
  routes = {
    clickops = {
      namespace            = "aop"
      ignore_route_changes = true
    }
  }
}
```

### modules.tf

```hcl
module "volterra_route" {
  source   = "git::https://gitlab.gcp.fenaco.com/templates/terraform-modules/terraform-volterra.git//volterra_route?ref=v1.0.0"
  for_each  = local.routes
  
  platform  = local.platform
  namespace = each.value.namespace
  key       = each.key
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
| [volterra_route.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/route) | resource |
| [volterra_route.ignore_route_changes](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ignore_route_changes"></a> [ignore\_route\_changes](#input\_ignore\_route\_changes) | n/a | `bool` | `false` | no |
| <a name="input_key"></a> [key](#input\_key) | n/a | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->