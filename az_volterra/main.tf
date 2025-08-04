#########################################################
### Volterra
#########################################################

resource "volterra_known_label_key" "provider" {
  key       = "azure-${var.key}-provider"
  namespace = "shared"
}

resource "volterra_known_label_key" "region" {
  key       = "azure-${var.key}-region"
  namespace = "shared"
}

resource "volterra_known_label" "cloudprovider" {
  key       = volterra_known_label_key.provider.key
  namespace = "shared"
  value     = var.value.f5_label_cloudprovider
}

resource "volterra_known_label" "cloudregion" {
  key       = volterra_known_label_key.region.key
  namespace = "shared"
  value     = var.value.f5_label_cloudregion
}

resource "volterra_virtual_site" "default" {
  name      = "vsite-azure-${var.key}"
  namespace = "shared"
  site_type = var.value.f5_site_type

  site_selector {
    expressions = [
      "${volterra_known_label_key.provider.key} in (${var.value.f5_label_cloudprovider}), ${volterra_known_label_key.region.key} in (${var.value.f5_label_cloudregion})",
    ]
  }
}

resource "volterra_securemesh_site_v2" "default" {
  for_each  = var.value.securemesh_site
  name      = "sms-azure-${var.key}-${each.key}-${var.value.f5_random_id}"
  namespace = var.value.f5_namespace
  enable_ha = var.value.f5_enable_ha

  // One of the arguments from this list "block_all_services blocked_services" must be set

  block_all_services = true

  // One of the arguments from this list "log_receiver logs_streaming_disabled" must be set

  logs_streaming_disabled = true

  labels = {
    (volterra_known_label_key.provider.key) = var.value.f5_label_cloudprovider,
    (volterra_known_label_key.region.key)   = var.value.f5_label_cloudregion
  }

  offline_survivability_mode {
    enable_offline_survivability_mode = false
  }

  // Use RE Site that is geographically closest to CE Site
  re_select {
    geo_proximity = true
  }

  // One of the arguments from this list "aws azure baremetal gcp kvm nutanix oci openstack rseries vmware" must be set

  azure {
    not_managed {}
  }
  lifecycle {
    ignore_changes = [
      labels,
    ]
  }
}

resource "volterra_token" "default" {
  for_each  = var.value.securemesh_site
  name      = "token-${var.key}-${each.key}"
  namespace = var.value.f5_namespace
  type      = "1"
  site_name = volterra_securemesh_site_v2.default[each.key].name
  depends_on = [
    volterra_securemesh_site_v2.default
  ]
  lifecycle {
    replace_triggered_by = [
      terraform_data.vm_replacement
    ]
  }
}

data "cloudinit_config" "f5xc-ce_config" {
  for_each      = var.value.securemesh_site
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = [
        {
          path        = "/etc/vpm/user_data"
          permissions = "0644"
          owner       = "root"
          content     = <<-EOT
            token: ${trimprefix(trimprefix(volterra_token.default[each.key].id, "id="), "\"")}
          EOT
        }
      ]
      runcmd = [
        "mkdir -p /home/admin/.ssh",
        "chmod 700 /home/admin/.ssh",
        "chown admin:admin /home/admin/.ssh",
        "echo '${base64decode(var.ssh_key)}' | sudo tee /home/admin/.ssh/authorized_keys > /dev/null",
        "chmod 600 /home/admin/.ssh/authorized_keys",
        "chown admin:admin /home/admin/.ssh/authorized_keys",
        "passwd -d admin"
      ]
    })
  }
}

#########################################################
### Azure
#########################################################

data "azurerm_resource_group" "default" {
  name = var.value.azure_resource_group_name
}

data "azurerm_virtual_network" "default" {
  name                = var.value.azure_virtual_network_name
  resource_group_name = var.value.azure_resource_group_name
}

data "azurerm_subnet" "inside" {
  for_each             = var.value.securemesh_site
  name                 = each.value.azure_inside_subnet_name
  virtual_network_name = var.value.azure_virtual_network_name
  resource_group_name  = var.value.azure_resource_group_name
}

data "azurerm_network_security_group" "inside" {
  for_each            = var.value.securemesh_site
  name                = each.value.azure_security_group_name_inside
  resource_group_name = var.value.azure_resource_group_name
}

resource "azurerm_network_interface" "nic-inside" {
  for_each              = var.value.securemesh_site
  name                  = "nic-f5xc-inside-${var.key}-sn-${each.key}"
  location              = var.value.azure_region
  resource_group_name   = var.value.azure_resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ip-internal"
    subnet_id                     = data.azurerm_subnet.inside[each.key].id
    private_ip_address_allocation = var.value.azure_private_ip_address_allocation
    private_ip_address            = each.value.static_ip.inside.ip_address
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "inside" {
  for_each                  = var.value.securemesh_site
  network_interface_id      = azurerm_network_interface.nic-inside[each.key].id
  network_security_group_id = data.azurerm_network_security_group.inside[each.key].id
}

data "azurerm_subnet" "outside" {
  for_each             = var.value.securemesh_site
  name                 = each.value.azure_outside_subnet_name
  virtual_network_name = var.value.azure_virtual_network_name
  resource_group_name  = var.value.azure_resource_group_name
}

data "azurerm_network_security_group" "outside" {
  for_each            = var.value.securemesh_site
  name                = each.value.azure_security_group_name_outside
  resource_group_name = var.value.azure_resource_group_name
}

resource "azurerm_public_ip" "ip-public" {
  for_each            = var.value.securemesh_site
  name                = "pip-f5xc-ce-${var.key}-sn-${each.key}"
  resource_group_name = var.value.azure_resource_group_name
  location            = var.value.azure_region
  allocation_method   = var.value.azure_virtual_machine_allocation_method
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface" "nic-outside" {
  for_each              = var.value.securemesh_site
  name                  = "nic-f5xc-outside-${var.key}-sn-${each.key}"
  location              = var.value.azure_region
  resource_group_name   = var.value.azure_resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ip-external"
    subnet_id                     = data.azurerm_subnet.outside[each.key].id
    private_ip_address_allocation = var.value.azure_private_ip_address_allocation
    private_ip_address            = each.value.static_ip.outside.ip_address
    public_ip_address_id          = azurerm_public_ip.ip-public[each.key].id
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "outside" {
  for_each                  = var.value.securemesh_site
  network_interface_id      = azurerm_network_interface.nic-outside[each.key].id
  network_security_group_id = data.azurerm_network_security_group.outside[each.key].id
}

resource "terraform_data" "vm_replacement" {
  input = var.value.f5_random_id
}

resource "azurerm_linux_virtual_machine" "default" {
  for_each            = var.value.securemesh_site
  name                = "vm-f5xc-ce-${var.key}-sn-${each.key}"
  location            = var.value.azure_region
  resource_group_name = var.value.azure_resource_group_name
  size                = var.value.azure_vm_size


  network_interface_ids = [
    azurerm_network_interface.nic-outside[each.key].id,
    azurerm_network_interface.nic-inside[each.key].id,
  ]
  admin_username                  = var.value.azure_vm_admin_username
  computer_name                   = "vm-f5xc-ce-${var.key}-sn-${each.key}"
  disable_password_authentication = var.value.azure_vm_disable_password_authentication

  admin_ssh_key {
    username   = var.value.azure_vm_admin_username
    public_key = base64decode(var.ssh_key)
  }


  os_disk {
    name                 = "osdiskf5xcce${var.key}sn${each.key}"
    caching              = var.value.azure_os_caching
    storage_account_type = var.value.azure_storage_accout_typ
  }

  plan {
    name      = var.value.f5_plan_name
    publisher = var.value.f5_plan_publisher
    product   = var.value.f5_plan_product
  }

  source_image_reference {
    publisher = var.value.f5_source_image_reference_publisher
    offer     = var.value.f5_source_image_reference_offer
    sku       = var.value.f5_source_image_reference_sku
    version   = var.value.f5_source_image_reference_version
  }

  custom_data = base64encode(data.cloudinit_config.f5xc-ce_config[each.key].rendered)
  depends_on  = [data.azurerm_resource_group.default]
  lifecycle {
    ignore_changes = [
      tags, custom_data, identity
    ]
    replace_triggered_by = [
      terraform_data.vm_replacement
    ]
  }
}
