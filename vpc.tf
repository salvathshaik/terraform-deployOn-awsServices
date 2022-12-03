module "vpc" {
  source          = "terraform-aws-modules/vpc/aws" #this module will download at the time of running
  name            = var.VPC_NAME
  cidr            = var.VpcCIDR
  azs             = [var.Zone1, var.Zone2,var.Zone3]
  private_subnets = [var.PriSub1CIDR, var.PriSub2CIDR, var.PriSub3CIDR]
  public_subnets  = [var.PubSub1CIDR, var.PubSub2CIDR, var.PubSub3CIDR]

  #we will also need to add nat_gateway but if you have multiple subnets so it will create multiple nate-gateways but for our exercise we will create single nat_gateway

  #and also enabling DNS-hostame and ports

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    terraform   = "true"
    environment = "Prod"
  }

  vpc_tags = {
    name = var.VPC_NAME
  }
}
