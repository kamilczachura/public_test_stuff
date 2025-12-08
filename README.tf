module "global_accelerator" {
  source = "./modules/global-accelerator"

  name           = "moj-global-accelerator"
  endpoint_region = "eu-central-1"
  
  load_balancer_arns = [
    "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/alb-1/abc123",
    "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/alb-2/def456",
    "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/alb-3/ghi789"
  ]

  tags = {
    Environment = "production"
    Project     = "moj-projekt"
  }
}

output "ga_static_ips" {
  value = module.global_accelerator.static_ip_addresses
}

output "ga_dns_name" {
  value = module.global_accelerator.accelerator_dns_name
}
