
output "backend_address_id" {
    description = "Id of the backend address pool created"
    value       = azurerm_lb_backend_address_pool.load_balancer.id
    depends_on = [
      azurerm_lb_backend_address_pool.load_balancer
    ]
}

output "public_ip_address" {
    description = "Public IP allocated to the load balancer"
    value       = var.public ? azurerm_public_ip.load_balancer[0].ip_address : null
    depends_on = [
      azurerm_public_ip.load_balancer
    ]
}