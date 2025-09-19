####################################################################################################################################################
### Volterra #######################################################################################################################################
####################################################################################################################################################
# This resource creates a Volterra Virtual Site that is used to manage the secure mesh sites.
resource "volterra_known_label_key" "provider" {
  key       = "gcp-${var.key}-provider"
  namespace = "shared"
}

resource "volterra_known_label_key" "region" {
  key       = "gcp-${var.key}-region"
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
  name      = "vsite-gcp-${var.key}"
  namespace = "shared"
  site_type = var.value.f5_site_type

  site_selector {
    expressions = [
      "${volterra_known_label_key.provider.key} in (${var.value.f5_label_cloudprovider}), ${volterra_known_label_key.region.key} in (${var.value.f5_label_cloudregion})",
    ]
  }
}

####################################################################################################################################################
# This resource creates a Volterra Secure Mesh Site and for every site is one node defined.
resource "volterra_securemesh_site_v2" "default" {
  for_each  = var.value.securemesh_site
  name      = "sms-gcp-${var.key}-${each.key}-${var.value.f5_random_id}"
  namespace = var.value.f5_namespace
  enable_ha = var.value.f5_enable_ha

  block_all_services = true

  logs_streaming_disabled = true

  labels = {
    (volterra_known_label_key.provider.key) = var.value.f5_label_cloudprovider,
    (volterra_known_label_key.region.key)   = var.value.f5_label_cloudregion
  }

  admin_user_credentials {
    ssh_key = var.value.gcp_vm_ssh_key
  }

  offline_survivability_mode {
    enable_offline_survivability_mode = false
  }

  re_select {
    geo_proximity = true
  }

  gcp {
    not_managed {}
  }
  depends_on = [volterra_virtual_site.default]
  lifecycle {
    ignore_changes = [labels]
  }
}

####################################################################################################################################################
# This resource creates a Volterra Token that is used by the Compute Instances to authenticate with the Secure Mesh Site.
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
      volterra_securemesh_site_v2.default[each.key].id
    ]
  }
}

####################################################################################################################################################
# This resource create a Cloud-init configuration that is used to configure the Compute Instances.
data "cloudinit_config" "default" {
  for_each      = var.value.securemesh_site
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = [
        # Puts the Volterra Token into a file that is used by the F5 XC to authenticate with the Secure Mesh Site.
        {
          path        = "/etc/vpm/user_data"
          permissions = "0644"
          owner       = "root"
          content     = <<-EOT
            token: ${trimprefix(trimprefix(volterra_token.default[each.key].id, "id="), "\"")}
          EOT
        },
      ]
    })
  }
}


####################################################################################################################################################
### Networking #####################################################################################################################################
####################################################################################################################################################
# These modules create the Inside and Outside VPCs that are needed. One inside and one outside per node and per secruemesh site.
module "inside-vpc" {
  source   = "terraform-google-modules/network/google//modules/vpc"
  version  = "~> 12.0"
  for_each = var.value.securemesh_site

  project_id                             = var.service_project_id
  network_name                           = join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))
  delete_default_internet_gateway_routes = true
  mtu                                    = 1460
  bgp_best_path_selection_mode           = "STANDARD"
}

module "outside-vpc" {
  source   = "terraform-google-modules/network/google//modules/vpc"
  version  = "~> 12.0"
  for_each = var.value.securemesh_site

  project_id                             = var.service_project_id
  network_name                           = join("-", slice(split("-", each.value.gcp_outside_subnet_name), 1, 7))
  delete_default_internet_gateway_routes = true
  mtu                                    = 1460
  bgp_best_path_selection_mode           = "STANDARD"
}

####################################################################################################################################################
# This resource creates the peerings between the Inside / Outside VPCs and the Shared VPC. Both sides of the peering are created here and only the routes from the Shared VPC are exported to the Inside and Outside VPCs.
resource "google_compute_network_peering" "inside-peering-1" {
  for_each     = var.value.securemesh_site
  name         = "vpc-fenit-sharedvpc-1-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))}"
  network      = "projects/${var.service_project_id}/global/networks/${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))}"
  peer_network = local.sharedvpc_id
}

resource "google_compute_network_peering" "inside-peering-2" {
  for_each     = var.value.securemesh_site
  name         = "vpc-fenit-sharedvpc-1-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))}"
  network      = local.sharedvpc_id
  peer_network = "projects/${var.service_project_id}/global/networks/${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))}"
}

####################################################################################################################################################
# These modules create the Inside and Outside Subnets that are needed. One Subnet per VPC. That is done because Google Cloud Instances can only be attached to a VPC once and the F5 XC needs two interfaces, one for the Inside and one for the Outside network.
module "inside-subnets" {
  for_each = var.value.securemesh_site
  source   = "terraform-google-modules/network/google//modules/subnets"
  version  = "~> 12.0"

  project_id   = var.service_project_id
  network_name = join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))
  subnets = [{
    subnet_name           = each.value.gcp_inside_subnet_name
    subnet_ip             = each.value.gcp_inside_subnet_range
    subnet_region         = var.region
    description           = "Inside Network"
    subnet_flow_logs      = true
    subnet_private_access = true
  }]
  depends_on = [module.inside-vpc]
}

module "outside-subnets" {
  for_each = var.value.securemesh_site
  source   = "terraform-google-modules/network/google//modules/subnets"
  version  = "~> 12.0"

  project_id   = var.service_project_id
  network_name = join("-", slice(split("-", each.value.gcp_outside_subnet_name), 1, 7))
  subnets = [{
    subnet_name           = each.value.gcp_outside_subnet_name
    subnet_ip             = each.value.gcp_outside_subnet_range
    subnet_region         = var.region
    description           = "Outside Network"
    subnet_flow_logs      = true
    subnet_private_access = true
  }]
  depends_on = [module.outside-vpc]
}


#####################################################################################################################################################
# These modules create the routes for the Inside and Outside VPCs. The routes are needed to route traffic to the Internet.
module "outside-routes" {
  for_each = var.value.securemesh_site
  source   = "terraform-google-modules/network/google//modules/routes"
  version  = "~> 12.0"

  ## Variables
  project_id   = var.service_project_id
  network_name = join("-", slice(split("-", each.value.gcp_outside_subnet_name), 1, 7))
  routes = [
    #########################################################################################################
    {
      name              = "default-route-to-internet-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 1, 7))}"
      destination_range = "0.0.0.0/0"
      description       = "Default route to the Internet."
      next_hop_internet = true
      priority          = "1001"
    },
    #########################################################################################################
  ]
}


####################################################################################################################################################
# These modules create the firewall rules for the Inside and Outside VPCs. The rules are needed to allow traffic from and to the F5 XC instances.
module "inside-firewall_rules" {
  for_each = var.value.securemesh_site
  source   = "terraform-google-modules/network/google//modules/firewall-rules"
  version  = "~> 12.0"

  ## Variables
  project_id   = var.service_project_id
  network_name = join("-", slice(split("-", each.value.gcp_inside_subnet_name), 1, 7))
  ingress_rules = [
    #########################################################################################################
    {
      name          = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 3, 7))}-ingress-ssh"
      description   = "Built by Terraform"
      priority      = 1000
      target_tags   = [var.value.f5_network_tag]
      source_ranges = ["172.16.0.0/12"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
  ]
  egress_rules = [
    #########################################################################################################
    {
      name               = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 3, 7))}-egress-allow-f5"
      description        = "Built by Terraform"
      priority           = 1000
      target_tags        = [var.value.f5_network_tag]
      destination_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
    {
      name               = "fw-bison-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 3, 7))}-egress-deny-all"
      description        = "Built by Terraform"
      priority           = 65535
      destination_ranges = ["0.0.0.0/0"]
      deny = [
        {
          protocol = "all"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
  ]

  depends_on = [
    module.inside-vpc
  ]
}

module "outside-firewall_rules" {
  for_each = var.value.securemesh_site
  source   = "terraform-google-modules/network/google//modules/firewall-rules"
  version  = "~> 12.0"

  ## Variables
  project_id   = var.service_project_id
  network_name = join("-", slice(split("-", each.value.gcp_outside_subnet_name), 1, 7))
  ingress_rules = [
    #########################################################################################################
    {
      name          = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 3, 7))}-ingress-icmp"
      description   = "Built by Terraform"
      priority      = 1000
      target_tags   = [var.value.f5_network_tag]
      source_ranges = ["195.245.237.0/24", "193.200.144.0/24"]
      allow = [
        {
          protocol = "icmp"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
    {
      name          = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 3, 7))}-ingress-ssh"
      description   = "Built by Terraform"
      priority      = 1000
      target_tags   = [var.value.f5_network_tag]
      source_ranges = ["195.245.237.0/24", "193.200.144.0/24"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
    {
      name          = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 3, 7))}-ingress-allow-f5"
      description   = "Built by Terraform"
      priority      = 1000
      target_tags   = [var.value.f5_network_tag]
      source_ranges = ["5.182.213.0/25", "5.182.212.0/25", "5.182.213.128/25", "5.182.214.0/25", "84.54.60.0/25", "185.56.154.0/25", "159.60.160.0/24", "159.60.162.0/24", "159.60.188.0/24", "159.60.182.0/24", "159.60.178.0/24"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
  ]
  egress_rules = [
    #########################################################################################################
    {
      name               = "fw-tag-bison-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 3, 7))}-egress-allow-f5"
      description        = "Built by Terraform"
      priority           = 1000
      target_tags        = [var.value.f5_network_tag]
      destination_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
    {
      name               = "fw-bison-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 3, 7))}-egress-deny-all"
      description        = "Built by Terraform"
      priority           = 65535
      destination_ranges = ["0.0.0.0/0"]
      deny = [
        {
          protocol = "all"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    #########################################################################################################
  ]

  depends_on = [
    module.outside-vpc
  ]
}


####################################################################################################################################################
# These resources create the static IP addresses for the Inside and Outside networks. The addresses are used by the Compute Instances to communicate.
resource "google_compute_address" "inside" {
  for_each     = var.value.securemesh_site
  project      = var.service_project_id
  name         = "ip-${join("-", slice(split("-", each.value.gcp_inside_subnet_name), 2, 7))}"
  subnetwork   = "projects/${var.service_project_id}/regions/${var.region}/subnetworks/${each.value.gcp_inside_subnet_name}"
  address_type = "INTERNAL"
  address      = each.value.static_ip.inside.ip_address
  region       = var.region
  depends_on   = [module.inside-subnets]
}

resource "google_compute_address" "outside" {
  for_each     = var.value.securemesh_site
  project      = var.service_project_id
  name         = "ip-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 2, 7))}"
  subnetwork   = "projects/${var.service_project_id}/regions/${var.region}/subnetworks/${each.value.gcp_outside_subnet_name}"
  address_type = "INTERNAL"
  address      = each.value.static_ip.outside.ip_address
  region       = var.region
  depends_on   = [module.outside-subnets]
}

resource "google_compute_address" "external" {
  for_each     = var.value.securemesh_site
  project      = var.service_project_id
  name         = "ip-${join("-", slice(split("-", each.value.gcp_outside_subnet_name), 2, 6))}-external"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "terraform_data" "vm_replacement" {
  input = var.value.f5_random_id
}

####################################################################################################################################################
##### Instances ####################################################################################################################################
####################################################################################################################################################
# This resource creates the Compute Instances that are used to run the F5 XC. The instances are configured with the Cloud-init configuration and the Volterra Token.

resource "google_compute_instance" "default" {
  for_each     = var.value.securemesh_site
  project      = var.service_project_id
  name         = "inst-f5xc-${var.key}-${each.key}"
  machine_type = var.value.gcp_vm_machine_type
  zone         = each.value.gcp_vm_zone

  tags = [var.value.f5_network_tag]

  boot_disk {
    device_name = "autogen-vm-tmpl-boot-disk"
    initialize_params {
      image = var.value.gcp_vm_disk_image
      type  = var.value.gcp_vm_disk_type
      size  = var.value.gcp_vm_disk_size
    }
  }

  metadata = {
    VmDnsSetting = "ZonalPreferred"
    ssh-keys     = "${var.value.gcp_vm_username}:${var.value.gcp_vm_ssh_key}"
    user-data    = data.cloudinit_config.default[each.key].rendered
  }

  can_ip_forward = true

  network_interface {
    subnetwork = "projects/${var.service_project_id}/regions/${var.region}/subnetworks/${each.value.gcp_outside_subnet_name}"
    network_ip = google_compute_address.outside[each.key].address
    access_config {
      nat_ip = google_compute_address.external[each.key].address
    }
  }

  network_interface {
    subnetwork = "projects/${var.service_project_id}/regions/${var.region}/subnetworks/${each.value.gcp_inside_subnet_name}"
    network_ip = google_compute_address.inside[each.key].address
  }

  service_account {
    email = var.value.gcp_service_account
    scopes = compact([
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol"
    ])
  }
  depends_on = [volterra_securemesh_site_v2.default, data.cloudinit_config.default]
  lifecycle {
    replace_triggered_by = [
      terraform_data.vm_replacement
    ]
  }
}