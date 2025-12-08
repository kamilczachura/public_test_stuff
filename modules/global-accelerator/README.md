# terraform-aws-global-accelerator-alb

Terraform module to create an AWS Global Accelerator with a single listener and attach multiple ALBs (Application Load Balancers) to the same accelerator and listener.

Features:
- Create one Accelerator
- Create one Listener
- Create one Endpoint Group per ALB region and attach all ALBs within the same region to that Endpoint Group
- Support for optional weight and client IP preservation per ALB
- Configurable listener protocol and port ranges
- Configurable health check settings used for all endpoint groups

Usage example (see examples/complete for a full working example):

```hcl
module "ga" {
  source = "../.."

  name                  = "example-ga"
  ip_address_type       = "IPV4"
  listener_protocol     = "TCP"
  listener_port_ranges  = [{ from_port = 80, to_port = 80 }, { from_port = 443, to_port = 443 }]

  albs = [
    {
      arn                     = "arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/alb-1/abcd"
      region                  = "us-west-2"
      weight                  = 100
      client_ip_preservation  = true
    },
    {
      arn    = "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/alb-2/efgh"
      region = "eu-central-1"
    }
  ]

  tags = {
    Project = "global-accelerator"
  }
}
```

Notes and recommendations:
- Each Endpoint Group is created per region. This is required by Global Accelerator which configures traffic policies per region.
- For each ALB object in `albs`, `arn` and `region` are required keys. `weight` and `client_ip_preservation` are optional.
- Health check settings are shared across all endpoint groups by default. If you need per-region or per-group health checks, extend the module to accept a map of region->healthcheck config.
