output "name" {
    description = "Name of the load balancer created"
    value = azurerm_lb.load_balancer.name
    depends_on = [
      azurerm_lb.load_balancer
    ]
}

output "id" {
    description = "Created load balancer identification"
    value = azurerm_lb.load_balancer.id
    depends_on = [
      azurerm_lb.load_balancer
    ]
}

output "resource_group_name" {
    description = "Resource group load balancer was created in"
    value       = var.resource_group_name
    depends_on = [
      azurerm_lb.load_balancer
    ]
}

output "region" {
    description = "Region where load balancer was created"
    value       = var.region
    depends_on = [
      azurerm_lb.load_balancer
    ]
}

output "platform" {
    description = "Platform for load balancer"
    value       = "Azure"
    depends_on = [
      azurerm_lb.load_balancer
    ]
}

output "backend_address_id_v4" {
    description = "Id of the backend IPv4 address pool created"
    value       = var.use_ipv4 ? azurerm_lb_backend_address_pool.load_balancer_v4[0].id : null
    depends_on  = [
      azurerm_lb_backend_address_pool.load_balancer_v4
    ]
}

output "backend_address_id_v6" {
    description = "Id of the backend IPv6 address pool created"
    value       = var.use_ipv6 ? azurerm_lb_backend_address_pool.load_balancer_v6[0].id : null
    depends_on  = [
      azurerm_lb_backend_address_pool.load_balancer_v6
    ]  
}

output "public_ip_address_v4" {
    description = "Public IP (IPv4) allocated to the load balancer"
    value       = var.public && var.use_ipv4 ? var.public_ip_name_v4 == "" ? azurerm_public_ip.load_balancer_v4[0].ip_address : data.azurerm_public_ip.public_ip_v4[0].ip_address : null
    depends_on  = [
      azurerm_public_ip.load_balancer_v4
    ]
}

output "public_ip_address_v6" {
    description = "Public IP (IPv6) allocated to the load balancer"
    value       = var.public && var.use_ipv6 ? var.public_ip_name_v6 == "" ? azurerm_public_ip.load_balancer_v6[0].ip_address : data.azurerm_public_ip.public_ip_v6[0].ip_address : null
    depends_on  = [
      azurerm_public_ip.load_balancer_v6
    ]
}

output "public_fqdn_v4" {
  description = "FQDN allocated to IPv4 public IP address"
  value       = var.public && var.use_ipv4 && var.create_fqdn ? var.public_ip_name_v4 == "" ? azurerm_public_ip.load_balancer_v4[0].fqdn : data.azurerm_public_ip.public_ip_v4[0].fqdn : null
  depends_on  = [
    azurerm_public_ip.load_balancer_v4
  ]
}

output "public_fqdn_v6" {
  description = "FQDN allocated to IPv6 public IP address"
  value       = var.public && var.use_ipv6 ? var.public_ip_name_v6 == "" ? azurerm_public_ip.load_balancer_v6[0].fqdn : data.azurerm_public_ip.public_ip_v6[0].fqdn : null
  depends_on  = [
    azurerm_public_ip.load_balancer_v6
  ]
}

output "backend_pool_id_v4" {
  description = "Backend pool ID for IPv4"
  value       = var.use_ipv4 ? azurerm_lb_backend_address_pool.load_balancer_v4[0].id : null
  depends_on  = [
    azurerm_lb_backend_address_pool.load_balancer_v4
  ]
}

output "backend_pool_id_v6" {
  description = "Backend pool ID for IPv6"
  value       = var.use_ipv6 ? azurerm_lb_backend_address_pool.load_balancer_v6[0].id : null
  depends_on  = [
    azurerm_lb_backend_address_pool.load_balancer_v6
  ]
}