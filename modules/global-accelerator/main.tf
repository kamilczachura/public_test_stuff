# Create the Global Accelerator
resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.name
  enabled         = var.enabled
  ip_address_type = var.ip_address_type

  tags = var.tags
}

# Create a single listener for the accelerator.
# The listener will use the provided protocol and port ranges.
resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.arn
  protocol        = var.listener_protocol

  dynamic "port_ranges" {
    for_each = var.listener_port_ranges
    content {
      from_port = port_ranges.value.from_port
      to_port   = port_ranges.value.to_port
    }
  }
}

# Group ALBs by region so we can create one endpoint group per region.
locals {
  # Build distinct list of regions present in var.albs
  alb_regions = distinct([for a in var.albs : a["region"]])

  # Map region -> list of alb objects in that region
  albs_by_region = {
    for r in local.alb_regions :
    r => [for a in var.albs : a if a["region"] == r]
  }
}

# Create an endpoint group per region and attach all ALBs from that region.
resource "aws_globalaccelerator_endpoint_group" "by_region" {
  for_each = local.albs_by_region

  listener_arn          = aws_globalaccelerator_listener.this.arn
  endpoint_group_region = each.key

  # Health check settings (can be adjusted via variables)
  health_check_protocol = var.health_check_protocol
  health_check_port     = var.health_check_port
  health_check_path     = var.health_check_path
  threshold_count       = var.threshold_count

  # For each ALB in the region, add an endpoint_configuration
  dynamic "endpoint_configuration" {
    for_each = each.value
    content {
      endpoint_id                     = endpoint_configuration.value["arn"]
      weight                          = lookup(endpoint_configuration.value, "weight", 128)
      client_ip_preservation_enabled  = lookup(endpoint_configuration.value, "client_ip_preservation", false)
    }
  }

  tags = var.tags
}
