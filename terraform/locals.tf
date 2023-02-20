locals {
  default_tags = {
    application      = var.application_name
    environment_type = var.environment_type
    environment_name = var.environment_name
    team_name        = "jobs_cloud_migration"     # your team name e.g. "awesome"
    contact_email    = "xavier.garcia@xing.com"   # should be a mailing list e.g. "awesome@new-work.se"
    business_unit    = "lemon"                    # business unit name e.g. "lime"
    cost_center      = "12050"                    # to enable cost tracking e.g. "12345"
    provisioned_by   = "terraform blueprint model"
    #map-migrated     = "d-server-03s3zvveibw473" # add this tag for a migrated workload
  }
  # setup deployment
  terraform_bucket_name = "nw-bucket-terraform-state-nw-996758699345-${var.environment_name}" # bucket names need to be unique ${var.account_id}
  key                   = "${var.application_name}/${var.environment_name}/terraform.tfstate" # <APPLICATION>/<ENVIRONMENT>/terraform.tfstate
  region                = "eu-central-1"

}
