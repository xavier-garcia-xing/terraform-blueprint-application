locals {
  default_tags = {
    application      = var.application_name
    environment_type = var.environment_type
    environment_name = var.environment_name
    team_name        = "jobs_cloud_migration"     # your team name e.g. "awesome"
    contact_email    = "xavier.garcia@xing.com"   # should be a mailing list e.g. "awesome@new-work.se"
    business_unit    = "Xing.com Lemon"           # business unit name e.g. "lime"
    cost_center      = "12050"                    # to enable cost tracking e.g. "12345"
    provisioned_by   = "terraform blueprint model"
    version          = var.deployment_version
    #map-migrated     = "d-server-03s3zvveibw473" # add this tag for a migrated workload
  }
}
