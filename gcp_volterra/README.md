# GCP Volterra Site Module

Creates a Volterra Site in Google Cloud.

## Usage

To use this module, include it in your Terraform configuration as shown below:

### locals.tf

```hcl
locals {
  volterra = {
    p = {
      f5_label_cloudprovider = "gcp"
      f5_label_cloudregion   = "europe-west6"
      f5_namespace           = "system"
      f5_vsite_labels        = { mesh = "ves-io-GCP" }
      f5_site_type           = "CUSTOMER_EDGE"
      f5_enable_ha           = false
      f5_network_tag         = "fw-tag-egress-f5-allow-all"
      f5_random_id           = "48jkf"

      gcp_service_account = module.service_account["gce"].service_account.email
      gcp_vm_machine_type = "n2-standard-8"
      gcp_vm_disk_type    = "pd-standard"
      gcp_vm_disk_image   = "projects/mpi-f5-7626-networks-public/global/images/f5xc-ce-9202444-20250102052432"
      gcp_vm_disk_size    = 80
      gcp_vm_username     = "cloud-user"
      gcp_vm_ssh_key      = var.ssh_key

      securemesh_site = {
        01 = {

          gcp_inside_subnet_name   = "sb-vpc-bison-f5xc-${local.env}-site01-inside-europe-west6"
          gcp_inside_subnet_range  = "10.168.67.0/29"
          gcp_outside_subnet_name  = "sb-vpc-bison-f5xc-${local.env}-site01-outside-europe-west6"
          gcp_outside_subnet_range = "10.168.67.8/29"
          gcp_vm_zone              = local.gcp_az["c"]
          static_ip = {
            inside = {
              ip_address = "10.168.67.4"
            }
            outside = {
              ip_address = "10.168.67.12"
            }
          }
        }
        02 = {
          gcp_inside_subnet_name   = "sb-vpc-bison-f5xc-${local.env}-site02-inside-europe-west6"
          gcp_inside_subnet_range  = "10.168.67.16/29"
          gcp_outside_subnet_name  = "sb-vpc-bison-f5xc-${local.env}-site02-outside-europe-west6"
          gcp_outside_subnet_range = "10.168.67.24/29"
          gcp_vm_zone              = local.gcp_az["b"]
          static_ip = {
            inside = {
              ip_address = "10.168.67.20"
            }
            outside = {
              ip_address = "10.168.67.28"
            }
          }
        }
      }
    }
  }
}
```

### modules.tf

```hcl
module "gcp_volterra" {
  source   = "git::https://gitlab.gcp.fenaco.com/templates/terraform-modules/terraform-volterra.git//gcp_volterra?ref=v1.0.1"
  for_each = local.volterra

  # Variables
  service_project_id = local.service_project_id
  region             = local.region
  network_project_id = local.network_project_id
  sharedvpc_name     = local.sharedvpc_name
  key                = each.key
  value              = each.value
}
```

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
| <a name="module_inside-firewall_rules"></a> [inside-firewall\_rules](#module\_inside-firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | ~> 11.0 |
| <a name="module_inside-subnets"></a> [inside-subnets](#module\_inside-subnets) | terraform-google-modules/network/google//modules/subnets | ~> 11.0 |
| <a name="module_inside-vpc"></a> [inside-vpc](#module\_inside-vpc) | terraform-google-modules/network/google//modules/vpc | ~> 11.0 |
| <a name="module_outside-firewall_rules"></a> [outside-firewall\_rules](#module\_outside-firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | ~> 11.0 |
| <a name="module_outside-routes"></a> [outside-routes](#module\_outside-routes) | terraform-google-modules/network/google//modules/routes | ~> 11.0 |
| <a name="module_outside-subnets"></a> [outside-subnets](#module\_outside-subnets) | terraform-google-modules/network/google//modules/subnets | ~> 11.0 |
| <a name="module_outside-vpc"></a> [outside-vpc](#module\_outside-vpc) | terraform-google-modules/network/google//modules/vpc | ~> 11.0 |

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