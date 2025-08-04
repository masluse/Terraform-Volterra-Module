# Azure Volterra Site Module

Creates a Volterra Site in Azure Cloud.

## Usage

To use this module, include it in your Terraform configuration as shown below:

### locals.tf

```hcl
locals {
  volterra = {
    p = {
      f5_label_cloudprovider                   = "azure"
      f5_label_cloudregion                     = "switzerlandnorth"
      f5_namespace                             = "system"
      f5_random_id                             = "pro78"
      f5_site_type                             = "CUSTOMER_EDGE"
      f5_cluster_size                          = "1"
      f5_enable_ha                             = false
      f5_plan_name                             = "f5xccebyol"
      f5_plan_publisher                        = "f5-networks"
      f5_plan_product                          = "f5xc_customer_edge"
      f5_source_image_reference_publisher      = "f5-networks"
      f5_source_image_reference_offer          = "f5xc_customer_edge"
      f5_source_image_reference_sku            = "f5xccebyol"
      f5_source_image_reference_version        = "2024.44.1"
      azure_region                             = "switzerlandnorth"
      azure_resource_group_name                = "rg-f5xc-network-p-sn-1"
      azure_virtual_network_name               = "vnet-f5xc-mgmt-p-sn-1"
      azure_vm_size                            = "Standard_D8s_v4"
      azure_vm_admin_username                  = "cloud-user"
      azure_vm_disable_password_authentication = true
      azure_virtual_machine_allocation_method  = "Static"
      azure_private_ip_address_allocation      = "Static"
      azure_storage_accout_typ                 = "Premium_LRS"
      azure_os_caching                         = "ReadWrite"


      securemesh_site = {
        01 = {
          azure_inside_subnet_name          = "snet-f5xc-site01-inside-p-sn"
          azure_outside_subnet_name         = "snet-f5xc-site01-outside-p-sn"
          azure_security_group_name_inside  = "nsg-f5xc-site01-inside-p-sn"
          azure_security_group_name_outside = "nsg-f5xc-site01-outside-p-sn"
          static_ip = {
            inside = {
              ip_address = "10.164.8.4"
              default_gw = "10.164.8.1"
            }
            outside = {
              ip_address = "10.164.8.12"
              default_gw = "10.164.8.9"
            }
          }
          mtu = 1500
        }
        02 = {
          azure_inside_subnet_name          = "snet-f5xc-site02-inside-p-sn"
          azure_outside_subnet_name         = "snet-f5xc-site02-outside-p-sn"
          azure_security_group_name_inside  = "nsg-f5xc-site02-inside-p-sn"
          azure_security_group_name_outside = "nsg-f5xc-site02-outside-p-sn"
          static_ip = {
            inside = {
              ip_address = "10.164.8.20"
              default_gw = "10.164.8.17"
            }
            outside = {
              ip_address = "10.164.8.28"
              default_gw = "10.164.8.25"
            }
          }
          mtu = 1500
        }
      }
    }
  }
}
```

### modules.tf

```hcl
module "az_volterra" {
  source   = "git::https://gitlab.gcp.fenaco.com/templates/terraform-modules/terraform-volterra.git//az_volterra?ref=v1.0.1"
  for_each = local.volterra

  # Variables
  key     = each.key
  value   = each.value
  ssh_key = var.ssh_key
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.nic-inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.nic-outside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.outside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.ip-public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [terraform_data.vm_replacement](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [volterra_known_label.cloudprovider](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label) | resource |
| [volterra_known_label.cloudregion](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label) | resource |
| [volterra_known_label_key.provider](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label_key) | resource |
| [volterra_known_label_key.region](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/known_label_key) | resource |
| [volterra_securemesh_site_v2.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/securemesh_site_v2) | resource |
| [volterra_token.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/token) | resource |
| [volterra_virtual_site.default](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/virtual_site) | resource |
| [azurerm_network_security_group.inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |
| [azurerm_network_security_group.outside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |
| [azurerm_resource_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subnet.outside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [cloudinit_config.f5xc-ce_config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key"></a> [key](#input\_key) | n/a | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `any` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->