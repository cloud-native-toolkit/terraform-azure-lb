module "azure_lb_public" {
  source = "./module"


    name_prefix             = "public-lb"
    resource_group_name     = module.resource_group.name
    region                  = var.region
    public                  = true
    lb_sku                  = "Standard"
    public_ip_sku           = "Standard"
    public_ip_allocation    = "Static"
    outbound_rule           = false     // This needs to be changed when SNAT can be disabled

    lb_rules = [{
        name = "api-external-rule"
        protocol = "Tcp"
        probe_name = "api-external-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false 
    }]

    lb_probes = [{
        name = "api-external-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"        
    }]
}

module "azure_lb_internal" {
  source = "./module"

    name_prefix         = "internal-lb"
    resource_group_name = module.resource_group.name
    region              = var.region
    public              = false
    subnet_id           = module.subnets.ids[0]
    lb_sku              = "Standard"

    lb_rules            = [{
        name = "api-internal-rule"
        protocol = "Tcp"
        probe_name = "api-internal-probe"
        frontend_port = 6443
        backend_port = 6443
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false
    },
    {
        name = "sint-rule"
        protocol = "Tcp"
        probe_name = "sint-probe"
        frontend_port = 22623
        backend_port = 22623
        idle_timeout = 30
        load_distribution = "Default"
        enable_floating_point = false        
    }]

    lb_probes = [{
        name = "api-internal-probe"
        interval = 5
        no_probes = 2
        port = 6443
        request_path = "/readyz"
        protocol = "Https"
    },
    {
        name = "sint-probe"
        interval = 5
        no_probes = 2
        port = 22623
        request_path = "/healthz"
        protocol = "Https"
    }]
}