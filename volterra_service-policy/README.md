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
| [volterra_service_policy.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/service_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key"></a> [key](#input\_key) | A unique identifier for the service policy. This is used to create a distinct name for the service policy resource. | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | The platform for which the Volterra resources are being configured. This is used to differentiate between different environments or deployments. | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | An object containing the configuration values for the service policy, including the namespace and optional lists of IPv4 and IPv6 prefixes. | <pre>object({<br/>    namespaces    = list(string)<br/>    prefixes      = optional(list(string), [])<br/>    ipv6_prefixes = optional(list(string), [])<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->