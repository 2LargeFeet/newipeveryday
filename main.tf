module "network" {
    source="./modules/network"

    cidr_block = var.cidr_block
    cidr_subnet = var.cidr_subnet
}

module "instance" {
    source="./modules/instance"

    private_key = var.private_key
    private_key_file = var.private_key_file

    security_group = module.network.security_group
    subnet = module.network.subnet
}