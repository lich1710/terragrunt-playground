include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//webservers"

  extra_arguments "init_args" {
    commands = [
      "init"
    ]

    arguments = [
    ]
  }
}

dependency "vpc" {
  config_path = "../../infrastructure/vpc"
}

dependency "external_alb" {
  config_path = "../../infrastructure/lb/ext-alb"
}

dependency "external_security_group" {
  config_path = "../../infrastructure/lb/ext-sg"
}

inputs = {
  available_zones               = dependency.vpc.outputs.azs
  vpc_id                        = dependency.vpc.outputs.vpc_id
  private_subnet_ids            = dependency.vpc.outputs.private_subnets
  public_subnet_ids             = dependency.vpc.outputs.public_subnets # Set Inputs
  company_name                  = "and"
  project_name                  = "Terragrunt Medium" # listener configuration 
  external_lb_security_group_id = dependency.external_security_group.outputs.security_group_id
  external_lb_listener_arn      = dependency.external_alb.outputs.http_tcp_listener_arns[0]
  external_lb_name              = dependency.external_alb.outputs.lb_dns_name
  external_lb_zone_id           = dependency.external_alb.outputs.lb_zone_id
  external_target_group_arns    = dependency.external_alb.outputs.target_group_arns

  tags = {
    Name        = "Terragrunt-VPC"
    Project     = "Terragrunt Medium"
    Environment = "Development"
  }
}