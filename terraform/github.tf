
data "aws_ssm_parameter" "openid_connect_provider_arn" {
  name        = format("%s_provider_arn", var.application_name)
}

data "aws_caller_identity" "current" {}
# Here, it is necessary to read the role, and modify it with new conditions. maybe the best is get the conditions from ssn and include one more
# or maybe just with make different roles...
/*
data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_ssm_parameter.openid_connect_provider_arn.value]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.git_domain}:${var.git_repo_root}/${var.application_name}:*"] #ref:refs/heads/main"]
    }
  }
}
# this is the "nw-role-github-actions" of the model. but it has reference to the github repositoy so it can't be general
resource "aws_iam_role" "github" {
  name                 = "${var.application_name}-github-deployment"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  max_session_duration = 3600
}
*/

