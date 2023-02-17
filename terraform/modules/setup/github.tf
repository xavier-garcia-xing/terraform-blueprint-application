data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Export  aws_iam_openid_connect_provider.github.arn in ssm service of aws to share with other modules
resource "aws_ssm_parameter" "provider_arn" {
  name        = format("%s_provider_arn", var.application_name)
  description = format("openid_provider ARN for github policy document for %s", var.application_name)
  type        = "String"
  value       = aws_iam_openid_connect_provider.github.arn
}


data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.git_repo_root}/${var.application_repo_name}:*"] #ref:refs/heads/main"]
    }
  }
}
# this is the "nw-role-github-actions" of the model. but it has reference to the github repositoy so it can't be general
resource "aws_iam_role" "github" {
  name                 = "${var.application_name}-github-deployment"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  max_session_duration = 3600
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
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "github_ecr_actions" {
  name        = "${var.application_name}-github-deployment-ecr-policy"
  description = "Grant Github Actions the ability to push to ECR"
  policy      = data.aws_iam_policy_document.github_ecr_actions.json
}

resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github_ecr_actions.arn
}

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

data "aws_iam_policy_document" "github_dift_actions" {
  statement {
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:DescribeScheduledActions",
      "autoscaling:DescribeLaunchConfigurations",
      "cloudformation:DescribeStacks",
      "cloudformation:GetTemplate",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudfront:ListTagsForResource",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeGlobalTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeTableReplicaAutoScaling",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTables",
      "dynamodb:ListTagsOfResource",
      "ec2:DescribeAddresses",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceCreditSpecifications",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcClassicLink",
      "ec2:DescribeVpcClassicLinkDnsSupport",
      "ec2:DescribeVpcs",
      "ec2:GetEbsEncryptionByDefault",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "elasticache:DescribeCacheClusters",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetUser",
      "iam:GetUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedGroupPolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupPolicies",
      "iam:ListGroups",
      "iam:ListPolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:ListUserPolicies",
      "iam:ListUsers",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListKeys",
      "kms:ListResourceTags",
      "lambda:GetEventSourceMapping",
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeGlobalClusters",
      "rds:ListTagsForResource",
      "route53:GetHealthCheck",
      "route53:GetHostedZone",
      "route53:ListHealthChecks",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "s3:GetAccelerateConfiguration",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "sns:GetSubscriptionAttributes",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource",
      "sns:ListTopics",
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "sqs:ListQueueTags"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "driftctl_policy" {
  name   = "${var.application_name}-github-deployment-driftctl-policy"
  role   = aws_iam_role.github.name
  policy = data.aws_iam_policy_document.github_dift_actions.json
}
/*
resource "aws_iam_role_policy" "terraform" {
  name   = "${var.application_name}-github-deployment"
  role   = aws_iam_role.github-actions.name
  policy = data.aws_iam_policy_document.terraform.json
}

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
}*/

