<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inside-firewall_rules"></a> [inside-firewall\_rules](#module\_inside-firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | ~> 12.0 |
| <a name="module_inside-subnets"></a> [inside-subnets](#module\_inside-subnets) | terraform-google-modules/network/google//modules/subnets | ~> 12.0 |
| <a name="module_inside-vpc"></a> [inside-vpc](#module\_inside-vpc) | terraform-google-modules/network/google//modules/vpc | ~> 12.0 |
| <a name="module_outside-firewall_rules"></a> [outside-firewall\_rules](#module\_outside-firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | ~> 12.0 |
| <a name="module_outside-routes"></a> [outside-routes](#module\_outside-routes) | terraform-google-modules/network/google//modules/routes | ~> 12.0 |
| <a name="module_outside-subnets"></a> [outside-subnets](#module\_outside-subnets) | terraform-google-modules/network/google//modules/subnets | ~> 12.0 |
| <a name="module_outside-vpc"></a> [outside-vpc](#module\_outside-vpc) | terraform-google-modules/network/google//modules/vpc | ~> 12.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.inside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.outside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network_peering.inside-peering-1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.inside-peering-2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [terraform_data.vm_replacement](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [volterra_known_label.cloudprovider](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label) | resource |
| [volterra_known_label.cloudregion](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label) | resource |
| [volterra_known_label_key.provider](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label_key) | resource |
| [volterra_known_label_key.region](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label_key) | resource |
| [volterra_securemesh_site_v2.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/securemesh_site_v2) | resource |
| [volterra_token.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/token) | resource |
| [volterra_virtual_site.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/virtual_site) | resource |
| [cloudinit_config.default](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key"></a> [key](#input\_key) | The key for the Volterra resources. | `string` | n/a | yes |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | The GCP project ID for the shared VPC network. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where the Volterra resources will be deployed. | `string` | n/a | yes |
| <a name="input_service_project_id"></a> [service\_project\_id](#input\_service\_project\_id) | The GCP project ID where the Volterra resources will be deployed. | `string` | n/a | yes |
| <a name="input_sharedvpc_name"></a> [sharedvpc\_name](#input\_sharedvpc\_name) | The name of the shared VPC network. | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->