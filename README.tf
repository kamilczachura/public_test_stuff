terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "global_accelerator_arns" {
  description = "List of Global Accelerator ARNs to protect with AWS Shield Advanced"
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to Shield protections"
  type        = map(string)
  default     = {}
}

# main.tf
resource "aws_shield_protection" "ga" {
  for_each = toset(var.global_accelerator_arns)

  name         = "shield-ga-${substr(md5(each.value), 0, 8)}"
  resource_arn = each.value

  tags = var.tags
}

# outputs.tf
output "protection_ids" {
  description = "List of Shield protection IDs for Global Accelerators"
  value       = [for p in aws_shield_protection.ga : p.id]
}

output "protected_gas" {
  description = "List of protected Global Accelerator ARNs"
  value       = [for p in aws_shield_protection.ga : p.resource_arn]
}
