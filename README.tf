terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "resource_arns" {
  description = "List of resource ARNs to protect with AWS Shield Advanced"
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to Shield protections"
  type        = map(string)
  default     = {}
}

# main.tf
resource "aws_shield_protection" "this" {
  for_each = toset(var.resource_arns)

  name         = "shield-protection-${replace(each.value, "/.*\\//", "")}"
  resource_arn = each.value

  tags = var.tags
}

# outputs.tf
output "protection_ids" {
  description = "Map of resource ARNs to their Shield protection IDs"
  value       = { for k, v in aws_shield_protection.this : k => v.id }
}

output "protected_resources" {
  description = "List of protected resource ARNs"
  value       = [for p in aws_shield_protection.this : p.resource_arn]
}
