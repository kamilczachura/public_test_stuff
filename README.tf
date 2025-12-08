terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "name" {
  description = "Name of the Global Accelerator"
  type        = string
}

variable "enabled" {
  description = "Whether the Global Accelerator should be enabled"
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "IP address type (IPV4 or DUAL_STACK)"
  type        = string
  default     = "IPV4"
}

variable "load_balancer_arns" {
  description = "List of Application/Network Load Balancer ARNs"
  type        = list(string)
}

variable "endpoint_region" {
  description = "Region where the load balancers are located"
  type        = string
}

variable "traffic_dial_percentage" {
  description = "Percentage of traffic directed to the endpoint group (0-100)"
  type        = number
  default     = 100
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Health check path (optional for ALB)"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Health check protocol (TCP, HTTP, HTTPS)"
  type        = string
  default     = "HTTPS"
}

variable "threshold_count" {
  description = "Number of consecutive health checks for status change"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}

# main.tf
resource "aws_globalaccelerator_accelerator" "main" {
  name            = var.name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled
  
  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.flow_logs.bucket
    flow_logs_s3_prefix = "flow-logs/"
  }

  tags = var.tags
}

resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.main.id
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "main" {
  listener_arn                  = aws_globalaccelerator_listener.https.id
  endpoint_group_region         = var.endpoint_region
  traffic_dial_percentage       = var.traffic_dial_percentage
  health_check_interval_seconds = var.health_check_interval_seconds
  health_check_path             = var.health_check_path
  health_check_protocol         = var.health_check_protocol
  threshold_count               = var.threshold_count

  dynamic "endpoint_configuration" {
    for_each = var.load_balancer_arns
    
    content {
      endpoint_id                    = endpoint_configuration.value
      weight                         = 128
      client_ip_preservation_enabled = true
    }
  }
}

# S3 bucket for flow logs (optional, can be removed if not needed)
resource "aws_s3_bucket" "flow_logs" {
  bucket = "${var.name}-ga-flow-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# outputs.tf
output "accelerator_id" {
  description = "Global Accelerator ID"
  value       = aws_globalaccelerator_accelerator.main.id
}

output "accelerator_dns_name" {
  description = "Global Accelerator DNS name"
  value       = aws_globalaccelerator_accelerator.main.dns_name
}

output "accelerator_hosted_zone_id" {
  description = "Hosted Zone ID for Route53"
  value       = aws_globalaccelerator_accelerator.main.hosted_zone_id
}

output "static_ip_addresses" {
  description = "Static IP addresses assigned to the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.main.ip_sets[0].ip_addresses
}

output "listener_id" {
  description = "Listener ID"
  value       = aws_globalaccelerator_listener.https.id
}

output "endpoint_group_id" {
  description = "Endpoint group ID"
  value       = aws_globalaccelerator_endpoint_group.main.id
}
