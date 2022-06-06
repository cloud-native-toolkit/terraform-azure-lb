module "subnets" {
  source = "github.com/cloud-native-toolkit/terraform-azure-subnets"

  resource_group_name = module.resource_group.name
  region              = var.region
  vpc_name            = module.vnet.name
  _count              = 2
  ipv4_cidr_blocks    = ["10.0.1.0/24", "10.0.2.0/24"]
  enabled             = var.enabled
  acl_rules           = []
}

resource "null_resource" "print_enabled" {
  provisioner "local-exec" {
    command = "echo -n '${module.subnets.enabled}' > .enabled"
  }
}
