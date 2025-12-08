variable "name" {
  description = "Name for the Global Accelerator"
  type        = string
  default     = "ga-accelerator"
}

variable "enabled" {
  description = "Whether the Global Accelerator is enabled"
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "IP address type for the Accelerator (IPV4 or DUAL_STACK)"
  type        = string
  default     = "IPV4"
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "listener_protocol" {
  description = "Protocol for the Global Accelerator listener (TCP or UDP)"
  type        = string
  default     = "TCP"
}

variable "listener_port_ranges" {
  description = "List of port ranges for the listener. Each item must be an object with from_port and to_port."
  type = list(object({
    from_port = number
    to_port   = number
  }))
  default = [
    { from_port = 80, to_port = 80 },
    { from_port = 443, to_port = 443 }
  ]
}

variable "albs" {
  description = <<-EOT
  List of ALB definitions to attach to the Global Accelerator. Each item should be an object
  containing at minimum:
    - arn: the ALB ARN
    - region: the region where the ALB is deployed

  Optional keys:
    - weight: numeric weight for the endpoint (default 128)
    - client_ip_preservation: boolean to enable client IP preservation for the endpoint (default false)

  Example:
    [
      {
        arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/my-alb/abcd1234"
        region = "us-west-2"
        weight = 100
        client_ip_preservation = true
      },
      {
        arn = "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/my-alb/efgh5678"
        region = "eu-central-1"
      }
    ]
  EOT
  type    = list(any)
  default = []
}

variable "health_check_protocol" {
  description = "Health check protocol used by endpoint groups"
  type        = string
  default     = "TCP"
}

variable "health_check_port" {
  description = "Health check port used by endpoint groups. Use 0 to let the provider pick a default."
  type        = number
  default     = 0
}

variable "health_check_path" {
  description = "Health check path (only for HTTP/HTTPS health checks)"
  type        = string
  default     = "/"
}

variable "threshold_count" {
  description = "Number of consecutive health checks required before considering the endpoint healthy/unhealthy"
  type        = number
  default     = 3
}
