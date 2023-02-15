
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
      values   = ["repo:source.xing.com:xavier-garcia/${var.application_name}:ref:refs/heads/main"]
      #values   = ["repo:source.xing.com:xavier-garcia/blue-print-poc1:*"]
    }
  }
}


# this is the "nw-role-github-actions" of the model. but it has reference to the github repositoy so it can't be general
resource "aws_iam_role" "github-actions" {
  name                 = "${var.application_name}-github-deployment"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  max_session_duration = 3600
}



/*

data "aws_iam_policy_document" "terraform" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      #format("%s/cpt-registry/production/terraform.tfstate", aws_s3_bucket.state.arn)
      format("%s/${var.application_name}/${var.environment_name}/terraform.tfstate", aws_s3_bucket.state.arn)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }
}

resource "aws_iam_role_policy" "terraform" {
  name   = "${var.application_name}-github-deployment"
  role   = aws_iam_role.github-actions.name
  policy = data.aws_iam_policy_document.terraform.json
}

data "aws_iam_policy_document" "github_ecr_actions" {
  statement {
      actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      ]
      resources = ["*"]
      condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/permit-github-action"

      values = ["true"]
      }
    }
  }

  resource "aws_iam_role_policy" "github_ecr_actions" {
  name        = "${var.application_name}-github-terraform"
  #description = "Grant Github Actions the ability to push to ECR"
  role        = aws_iam_role.github-actions.name
  policy      = data.aws_iam_policy_document.github_ecr_actions.json
  }



  /*resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
  }*/
/*
  resource "aws_ecr_repository" "repo" {
  name                 = "jobs-cloud-migration/${var.application_name}"
  image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        "permit-github-action" = true
    }
  }
 */
/*
resource "aws_iam_role_policy_attachment" "ecr_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.github.name
}

resource "aws_iam_role_policy_attachment" "kms" {
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  role       = aws_iam_role.github.name
}

data "aws_iam_policy_document" "iam" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:PutRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:GetPolicy",
      "iam:ListRoles",
      "iam:DeleteRole",
      "iam:TagRole"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "terraform" {
  name   = "${var.application_name}-github-terraform"
  role   = aws_iam_role.github-actions.name
  policy = data.aws_iam_policy_document.terraform.json
}
*/