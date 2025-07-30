# Volterra Namespace Module

Creates a Volterra Namespace.

## Usage

To use this module, include it in your Terraform configuration as shown below:

### locals.tf

```hcl
locals {
  namespaces = {
    aop = {}
  }
}
```

### modules.tf

```hcl
module "volterra_namespace" {
  source   = "git::https://gitlab.gcp.fenaco.com/templates/terraform-modules/terraform-volterra.git//volterra_namespace?ref=v1.0.0"
  for_each = local.namespaces

  key      = each.key
  value    = each.value
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
| [volterra_namespace.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/namespace) | resource |
| [volterra_service_policy.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/service_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key"></a> [key](#input\_key) | Key for the Volterra namespace, used to differentiate between multiple namespaces | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | Platform for which the Volterra namespace is being configured | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | Value for the Volterra namespace, containing specific configuration details | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->