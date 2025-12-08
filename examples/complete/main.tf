# Example usage of the module
provider "aws" {
  region = "us-west-2"
}

module "ga_example" {
  source = "../../"

  name                 = "example-ga"
  ip_address_type      = "IPV4"
  listener_protocol    = "TCP"
  listener_port_ranges = [{ from_port = 80, to_port = 80 }, { from_port = 443, to_port = 443 }]

  # Example ALB entries: include arn and region. weight and client_ip_preservation are optional.
  albs = [
    {
      arn    = "arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/alb-1/abcd"
      region = "us-west-2"
      weight = 100
    },
    {
      arn    = "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/alb-2/efgh"
      region = "eu-central-1"
    }
  ]

  tags = {
    Environment = "demo"
    Owner       = "team"
  }
}
