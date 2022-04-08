# Create a load balancer and backend address pool

##
## TO do
## Add IPv6 support
## Is outbound rule required for public load balancer?

locals {
  frontend_name = "${var.name_prefix}-frontend"
  backend_name = "${var.name_prefix}-backend"
  public_ip_name = "${var.name_prefix}-publicIP"
  outbound_name = "${var.name_prefix}-outbound-rule"
}

resource "azurerm_public_ip" "load_balancer" {
    count = var.public ? 1 : 0

    name                = local.public_ip_name
    resource_group_name = var.resource_group_name
    location            = var.region
    allocation_method   = var.public_ip_allocation
    domain_name_label   = var.dns_label
    sku                 = var.public_ip_sku
}

resource "azurerm_lb" "load_balancer" {
    name                = var.name_prefix
    resource_group_name = var.resource_group_name
    location            = var.region
    sku                 = var.lb_sku

    frontend_ip_configuration {
        name                            = local.frontend_name
        public_ip_address_id            = var.public ? azurerm_public_ip.load_balancer[0].id : null
        subnet_id                       = var.public ? null : var.subnet_id
        private_ip_address_version      = var.public ? null : "IPv4"
        private_ip_address_allocation   = var.public ? null : var.private_ip_allocation
    }
}

resource "azurerm_lb_backend_address_pool" "load_balancer" {
    loadbalancer_id = azurerm_lb.load_balancer.id
    name            = local.backend_name
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
    backend_address_pool_ids        = [azurerm_lb_backend_address_pool.load_balancer.id]
    frontend_ip_configuration_name  = local.frontend_name
    probe_id                        = length(var.lb_probes) == 0 ? null : azurerm_lb_probe.load_balancer[each.value.probe_name].id
    
    name                            = each.value.name
    protocol                        = each.value.protocol
    frontend_port                   = each.value.frontend_port
    backend_port                    = each.value.backend_port
    load_distribution               = each.value.load_distribution
    idle_timeout_in_minutes         = each.value.idle_timeout
    enable_floating_ip              = each.value.enable_floating_point
}

// Following does not work without SNAT disabled
resource "azurerm_lb_outbound_rule" "load_balancer" {
    count = var.public && var.outbound_rule ? 1 : 0

    name                        = local.outbound_name
    loadbalancer_id             = azurerm_lb.load_balancer.id
    backend_address_pool_id     = azurerm_lb_backend_address_pool.load_balancer.id
    protocol                    = "All"

    frontend_ip_configuration {
      name = local.frontend_name
    }
}