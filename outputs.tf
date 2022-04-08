
output "backend_address_id" {
    description = "Id of the backend address pool created"
    value       = azurerm_lb_backend_address_pool.load_balancer.id
    depends_on  = [
      azurerm_lb_backend_address_pool.load_balancer
    ]
}

output "public_ip_address" {
    description = "Public IP allocated to the load balancer"
    value       = var.public ? azurerm_public_ip.load_balancer[0].ip_address : null
    depends_on  = [
      azurerm_public_ip.load_balancer
    ]
}

output "id" {
    description = "Created load balancer identification"
    value = azurerm_lb.load_balancer.id
}

output "resource_group_name" {
    description = "Resource group load balancer was created in"
    value       = var.resource_group_name
}

output "region" {
    description = "Region where load balancer was created"
    value       = var.region
}

output "platform" {
    description = "Platform for load balancer"
    value       = "Azure"
}