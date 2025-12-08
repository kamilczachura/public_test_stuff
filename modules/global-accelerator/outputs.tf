output "accelerator_arn" {
  description = "ARN of the created Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.arn
}

output "accelerator_id" {
  description = "ID of the created Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.id
}

output "listener_arn" {
  description = "ARN of the created Global Accelerator listener"
  value       = aws_globalaccelerator_listener.this.arn
}

output "endpoint_group_arns" {
  description = "Map of region -> endpoint group ARN"
  value = {
    for k, v in aws_globalaccelerator_endpoint_group.by_region :
    k => v.arn
  }
}

output "endpoint_group_ids" {
  description = "Map of region -> endpoint group id"
  value = {
    for k, v in aws_globalaccelerator_endpoint_group.by_region :
    k => v.id
  }
}
