# Terraform Volterra Module

This repository contains Terraform modules for deploying and managing resources on Volterra's platform, specifically focusing on Azure and Google Cloud Platform (GCP) site deployment and load balancer configuration.

## Key Features & Benefits

*   **Modular Design:** Well-structured modules for reusability and maintainability.
*   **Cloud Agnostic (GCP & Azure):** Supports deployments on both Google Cloud and Microsoft Azure.
*   **Automated Site Creation:** Simplifies the process of creating Volterra sites in different cloud environments.
*   **Load Balancer Configuration:** Enables easy setup and management of Volterra load balancers.
*   **Namespace Management:** Modules to assist in managing Volterra Namespaces

## Prerequisites & Dependencies

*   **Terraform:** Version 0.13 or higher.
*   **Volterra Account:** A valid Volterra account with necessary permissions.
*   **Azure Account (for Azure deployments):** An Azure subscription with appropriate access rights.
*   **GCP Account (for GCP deployments):** A Google Cloud project with appropriate access rights.
*   **Terraform Provider for Volterra:** Ensure the Volterra provider is configured.

## Installation & Setup Instructions

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/masluse/Terraform-Volterra-Module.git
    cd Terraform-Volterra-Module
    ```

2.  **Configure Terraform:**

    Initialize Terraform and install necessary providers:

    ```bash
    terraform init
    ```

3.  **Set up Volterra Provider:**

    Configure the Volterra provider with your API key, tenant, and endpoint.  Refer to the Volterra provider documentation for detailed instructions.

## Usage Examples

### Azure Volterra Site

```terraform
module "azure_volterra_site" {
  source = "./az_volterra"

  f5_label_cloudprovider = "azure"
  f5_label_cloudregion   = "switzerlandnorth"
  f5_namespace           = "system"
  f5_random_id           = "pro78"
  f5_site_type           = "CUSTOMER_EDGE"
  # ... other configuration options
}
```

Refer to `az_volterra/README.md` for detailed usage and configuration options.

### GCP Volterra Site

```terraform
module "gcp_volterra_site" {
  source = "./gcp_volterra"

  f5_label_cloudprovider = "gcp"
  f5_label_cloudregion   = "europe-west6"
  f5_namespace           = "system"
  f5_vsite_labels        = { mesh = "ves-io-GCP" }
  f5_site_type           = "CUSTOMER_EDGE"
  # ... other configuration options
}
```

Refer to `gcp_volterra/README.md` for detailed usage and configuration options.

### Volterra Loadbalancer

```terraform
module "volterra_loadbalancer" {
  source = "./volterra_loadbalancer"

  namespace      = "aop"
  tenant         = "bison-group-yybostat"
  site_name      = "vsite-gcp-p"
  site_namespace = "shared"
  # ... other configuration options
}
```

Refer to `volterra_loadbalancer/README.md` for detailed usage and configuration options.

## Configuration Options

Each module has specific configuration options defined in their respective `variables.tf` files.  Refer to the module's README for a detailed explanation of each option.  Here's a general overview:

*   **Azure Site:** `az_volterra/variables.tf`
*   **GCP Site:** `gcp_volterra/variables.tf`
*   **Load Balancer:** `volterra_loadbalancer/variables.tf`

## Contributing Guidelines

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Make your changes and ensure they are well-tested.
4.  Submit a pull request with a clear description of your changes.

## License Information

License not specified.

## Acknowledgments

*   Volterra for providing the platform and API.
*   Terraform community for their tools and resources.