
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
      #identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.git_domain}:${var.git_repo_root}/${var.application_name}:ref:refs/heads/main"]
    }
  }
}


# this is the "nw-role-github-actions" of the model. but it has reference to the github repositoy so it can't be general
resource "aws_iam_role" "github-actions" {
  name                 = "${var.application_name}-github-deployment"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  max_session_duration = 3600
}



