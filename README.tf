module "shield_protection" {
  source = "./modules/shield-protection"

  resource_arns = concat(
    module.MCI-Autoscaling.alb_arns,
    module.test.something,
    [module.global_accelerator.accelerator_id]  # pojedyncze wartości w []
  )
}
