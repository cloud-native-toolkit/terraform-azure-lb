# Create a load balancer and backend address pool

##
## TO do
## Is outbound rule required for public load balancer?

locals {
    name_prefix = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
    frontend_name_v4 = "${local.name_prefix}-frontend_v4"
    frontend_name_v6 = "${local.name_prefix}-frontend_v6"
    backend_name_v4 = "${local.name_prefix}-backend-ipv4"
    backend_name_v6 = "${local.name_prefix}-backend-ipv6"
    public_ip_name_v4 = "${local.name_prefix}-publicIP_v4"
    public_ip_name_v6 = "${local.name_prefix}-publicIP_v6"
    outbound_name_v4 = "${local.name_prefix}-outbound-rule_v4"
    outbound_name_v6 = "${local.name_prefix}-outbound-rule_v6"
    public_ip_id_v4 = var.public && var.use_ipv4 ? azurerm_public_ip.load_balancer_v4[0].id : null
    public_ip_id_v6 = var.public && var.use_ipv6 ? azurerm_public_ip.load_balancer_v6[0].id : null
    dns_label = var.dns_label != null ? var.dns_label : var.name_prefix
}

resource "azurerm_public_ip" "load_balancer_v4" {
    count = var.public && var.use_ipv4 ? 1 : 0

    name                = local.public_ip_name_v4
    resource_group_name = var.resource_group_name
    location            = var.region
    allocation_method   = var.public_ip_allocation
    domain_name_label   = var.create_fqdn ? local.dns_label : null
    sku                 = var.public_ip_sku
}

resource "azurerm_public_ip" "load_balancer_v6" {
    count = var.public && var.use_ipv6 ? 1 : 0

    name                = local.public_ip_name_v6
    resource_group_name = var.resource_group_name
    location            = var.region
    allocation_method   = var.public_ip_allocation
    domain_name_label   = var.create_fqdn ? local.dns_label : null
    sku                 = var.public_ip_sku
}

resource "azurerm_lb" "load_balancer" {
    name                = local.name_prefix
    resource_group_name = var.resource_group_name
    location            = var.region
    sku                 = var.lb_sku

    dynamic "frontend_ip_configuration" {
        for_each = [for ip in [
            {   name: local.frontend_name_v4, 
                ipv6: false, 
                addr_version: "IPv4",
                public_ip_id: local.public_ip_id_v4,
                include: var.use_ipv4 },
            {   name: local.frontend_name_v6, 
                ipv6: true, 
                addr_version: "IPv6",
                public_ip_id: local.public_ip_id_v6,
                include: var.use_ipv6 }
            ] : {
                name            : ip.name
                ipv6            : ip.ipv6
                addr_version    : ip.addr_version
                public_ip_id    : ip.public_ip_id
                include         : ip.include
            } if ip.include
        ]

        content {
            name                            = frontend_ip_configuration.value.name
            public_ip_address_id            = var.public ? frontend_ip_configuration.value.public_ip_id : null
            subnet_id                       = var.public ? null : var.subnet_id
            private_ip_address_version      = var.public ? null : frontend_ip_configuration.value.addr_version
            private_ip_address_allocation   = var.public ? null : var.private_ip_allocation
            private_ip_address              = frontend_ip_configuration.value.ipv6 ? cidrhost(var.subnet_cidr_v6, -2) : null
        }
    }
}

resource "azurerm_lb_backend_address_pool" "load_balancer_v4" {
    count = var.use_ipv4 ? 1 : 0

    loadbalancer_id = azurerm_lb.load_balancer.id
    name            = local.backend_name_v4
}

resource "azurerm_lb_backend_address_pool" "load_balancer_v6" {
    count = var.use_ipv6 ? 1 : 0

    loadbalancer_id = azurerm_lb.load_balancer.id
    name            = local.backend_name_v6
}

resource "azurerm_lb_probe" "load_balancer" {
    for_each = {for probe in var.lb_probes: probe.name => probe}

    loadbalancer_id         = azurerm_lb.load_balancer.id

    name                    = each.value.name
    interval_in_seconds     = each.value.interval
    number_of_probes        = each.value.no_probes
    port                    = each.value.port
    protocol                = each.value.protocol
    request_path            = each.value.request_path
}

resource "azurerm_lb_rule" "load_balancer" {
    for_each = {for rule in var.lb_rules: rule.name => rule}
    depends_on  = [azurerm_lb_probe.load_balancer]

    loadbalancer_id                 = azurerm_lb.load_balancer.id
    backend_address_pool_ids        = var.use_ipv6 ? [azurerm_lb_backend_address_pool.load_balancer_v6[0].id] : [azurerm_lb_backend_address_pool.load_balancer_v4[0].id]
    frontend_ip_configuration_name  = var.use_ipv6 ? local.frontend_name_v6 : local.frontend_name_v4
    probe_id                        = length(var.lb_probes) == 0 ? null : azurerm_lb_probe.load_balancer[each.value.probe_name].id
    
    name                            = each.value.name
    protocol                        = each.value.protocol
    frontend_port                   = each.value.frontend_port
    backend_port                    = each.value.backend_port
    load_distribution               = each.value.load_distribution
    idle_timeout_in_minutes         = each.value.idle_timeout
    enable_floating_ip              = each.value.enable_floating_point
    disable_outbound_snat           = var.outbound_rule && var.public ? true : false
}

// Following does not work without SNAT disabled
resource "azurerm_lb_outbound_rule" "load_balancer_v4" {
    count = var.public && var.outbound_rule && var.use_ipv4 ? 1 : 0

    name                        = local.outbound_name_v4
    loadbalancer_id             = azurerm_lb.load_balancer.id
    backend_address_pool_id     = azurerm_lb_backend_address_pool.load_balancer_v4[0].id
    protocol                    = var.outbound_protocol

    frontend_ip_configuration {
      name = local.frontend_name_v4
    }
}

resource "azurerm_lb_outbound_rule" "load_balancer_v6" {
    count = var.public && var.outbound_rule && var.use_ipv6 ? 1 : 0

    name                        = local.outbound_name_v6
    loadbalancer_id             = azurerm_lb.load_balancer.id
    backend_address_pool_id     = azurerm_lb_backend_address_pool.load_balancer_v6[0].id
    protocol                    = var.outbound_protocol

    frontend_ip_configuration {
      name = local.frontend_name_v6
    }
}