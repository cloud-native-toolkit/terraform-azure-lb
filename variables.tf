variable "resource_group_name" {
    type        = string
    description = "The name of the Azure resource group where the VPC has been provisioned"
}

variable "region" {
    type        = string
    description = "The Azure location where the load balancer will be installed"
}

variable "public" {
    type        = bool
    description = "Flag to indicate whether a public IP is required"
    default     = false
}

variable "outbound_rule" {
    type        = bool
    description = "Flag to indicate whether an outbound rule is required for a public load balancer"
    default     = false
}

variable "name_prefix" {
    type        = string
    description = "Prefix for the name of the load balancer to be created"
}

variable "subnet_id" {
    type        = string
    description = "The subnet id to attach the load balancer frontend if private"
    default     = null
}

variable "lb_sku" {
    type        = string
    description = "Azure Load Balancer SKU type - Basic, Standard or Gateway"
    default     = "Standard"
}

variable "private_ip_allocation" {
    type        = string
    description = "Private IP address allocation method - Static or Dynamic"
    default = "Dynamic"
}

variable "public_ip_allocation" {
    type        = string
    description = "Public IP address allocation method - Static or Dynamic"
    default     = "Static"
}

variable "dns_label" {
    type        = string
    description = "DNS label for public IP"
    default     = null
}

variable "public_ip_sku" {
    type = string
    description = "Public IP SKU - Basic or Standard"
    default = "Basic"
}

variable "lb_rules" {
    type = list(object({
        name=string,
        protocol=string,
        probe_name=string,
        frontend_port=number,
        backend_port=number,
        load_distribution=string,
        idle_timeout=number,
        enable_floating_point=bool
    }))
    description = "List of the load balancer rules to be created"
    default = []
}

variable "lb_probes" {
    type = list(object({
        name=string,
        interval=number,
        no_probes=number,
        port=number,
        request_path=string,
        protocol=string
    }))
    description = "List of probes to be created"
    default = []
}

variable "enabled" {
  type        = bool
  description = "Flag to indicate that module should be enabled"
  default     = true
}