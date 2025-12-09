# modules/alb-trust-store/variables.tf
variable "name" {
  description = "Trust store name"
  type        = string
}

variable "ca_bundle_s3_bucket" {
  description = "S3 bucket containing CA bundle"
  type        = string
}

variable "ca_bundle_s3_key" {
  description = "S3 key for CA bundle"
  type        = string
}

variable "alb_arns" {
  description = "List of ALB ARNs to associate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

# modules/alb-trust-store/main.tf
resource "aws_lb_trust_store" "this" {
  name                             = var.name
  ca_certificates_bundle_s3_bucket = var.ca_bundle_s3_bucket
  ca_certificates_bundle_s3_key    = var.ca_bundle_s3_key

  tags = var.tags
}

resource "aws_lb_trust_store_revocation" "this" {
  count = length(var.alb_arns)

  trust_store_arn            = aws_lb_trust_store.this.arn
  revocation_id              = count.index
  s3_bucket                  = var.ca_bundle_s3_bucket
  s3_key                     = var.ca_bundle_s3_key
  revocation_type            = "CRL"
}

resource "aws_lb_listener" "trust_store_association" {
  count = length(var.alb_arns)

  load_balancer_arn = var.alb_arns[count.index]
  
  mutual_authentication {
    mode            = "verify"
    trust_store_arn = aws_lb_trust_store.this.arn
  }
}

# modules/alb-trust-store/outputs.tf
output "trust_store_arn" {
  description = "Trust store ARN"
  value       = aws_lb_trust_store.this.arn
}

output "trust_store_id" {
  description = "Trust store ID"
  value       = aws_lb_trust_store.this.id
}

# Example usage in root module
# main.tf
module "alb_trust_store" {
  source = "./modules/alb-trust-store"

  name                  = "my-trust-store"
  ca_bundle_s3_bucket   = "my-bucket"
  ca_bundle_s3_key      = "ca-bundle.pem"
  
  alb_arns = [
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-1/xxx",
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-2/xxx",
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-3/xxx",
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-4/xxx",
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-5/xxx",
    "arn:aws:elasticloadbalancing:region:account:loadbalancer/app/alb-6/xxx",
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
