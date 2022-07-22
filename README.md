# Azure Load Balancer

## Module overview

### Description

Module that provisions an internal or public load balancer on Azure, including the following resources:
- public_ip (if a public load balancer)
- backend_address_pool
- lb_probes
- lb_rules
- outbound_rules
- FQDN for public IP

**Note:** This module follows the Terraform conventions regarding how provider configuration is defined within the Terraform template and passed into the module - https://www.terraform.io/docs/language/modules/develop/providers.html. The default provider configuration flows through to the module. If different configuration is required for a module, it can be explicitly passed in the `providers` block of the module - https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly.

### Software dependencies

The module depends on the following software components:

#### Command-line tools

- terraform >= v0.15

#### Terraform providers

- Azure provider >= 2.91.0

### Module dependencies

This module makes use of the output from other modules:

- Azure Resource group - github.com/cloud-native-toolkit/terraform-azure-resource-group
- Azure VNet - github.com/cloud-native-toolkit/terraform-azure-vnet
- Azure Subnets - github.com/cloud-native-toolkit/terraform-azure-subnets

### Example usage

```hcl-terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.91.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

module "internal_lb" {
    source = "github.com/cloud-native-toolkit/terraform-azure-lb"

    name_prefix         = "${var.name_prefix}-internal-lb"
    resource_group_name = module.resource_group.name
    region              = var.region
    public              = false
    subnet_id           = module.master_subnet.ids[0]
    lb_sku              = "Standard"
    use_ipv4            = true
    use_ipv6            = false

    lb_rules            = [{
        name = "${var.name_prefix}-api-internal-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-api-internal-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false
    },
    {
        name = "${var.name_prefix}-sint-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-sint-probe"
        frontend_port = 22623
        backend_port = 22623
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false        
    }]

    lb_probes = [{
        name = "${var.name_prefix}-api-internal-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"
    },
    {
        name = "${var.name_prefix}-sint-probe"
        interval = 5
        no_probes = 2
        port = 22623
        request_path = "/healthz"
        protocol = "Https"
    }]
}

module "public_lb" {
    source = "github.com/cloud-native-toolkit/terraform-azure-lb"

    name_prefix             = "${var.name_prefix}-public-lb"
    resource_group_name     = module.resource_group.name
    region                  = var.region
    public                  = true
    lb_sku                  = "Standard"
    public_ip_sku           = "Standard"
    public_ip_allocation    = "Static"
    outbound_rule           = false    
    use_ipv4                = true
    use_ipv6                = false
    dns_label               = "${var.name_prefix}-aro"
    create_fqdn             = true 

    lb_rules = [{
        name = "${var.name_prefix}-api-external-rule"
        protocol = "Tcp"
        probe_name = "${var.name_prefix}-api-external-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false 
    }]

    lb_probes = [{
        name = "${var.name_prefix}-api-external-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"        
    }]
}

```
