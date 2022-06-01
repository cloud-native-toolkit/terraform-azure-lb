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

variable "create_fqdn" {
    type        = bool
    description = "Create a FQDN from the name prefix as a subddomain of Azure (<name_prefix>.<region>.cloudapp.azure.com)"
    default     = true
}

variable "use_ipv4" {
    type        = bool
    description = "Support IPv4"
    default     = true
}

variable "use_ipv6" {
    type        = bool
    description = "Support IPv6"
    default     = false
}

variable "outbound_rule" {
    type        = bool
    description = "Flag to indicate whether an outbound rule is required for a public load balancer"
    default     = false
}

variable "outbound_protocol" {
    type        = string
    description = "Protocol for the outbound rule for a public load balancer"
    default     = "All"
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

variable "subnet_cidr_v6" {
    type        = string
    description = "Subnet CIDR from which to allocate a public IPv6 address"
    default     = ""
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

variable "public_ip_name_v4" {
    type = string
    description = "Public IP V4 Name"
    default = ""
}

variable "public_ip_name_v6" {
    type = string
    description = "Public IP V6 Name"
    default = ""
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