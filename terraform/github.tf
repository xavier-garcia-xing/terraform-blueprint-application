
locals {
  openid_connect_provider_key = format("%s_provider_arn", var.application_infra_name)
  sub_arn_key                 = format("arn:aws:ssm:%s:%s:parameter", var.region, var.account_id)
  arn_key_list                = formatlist("${local.sub_arn_key}/%s", var.ssm_parameters)
}

# Import the arn openid provider parameter from setup module
data "aws_ssm_parameter" "openid_connect_provider_arn" {
  name = local.openid_connect_provider_key
}


data "aws_caller_identity" "current" {}
# Here, it is necessary to read the role, and modify it with new conditions. maybe the best is get the conditions from ssn and include one more
# or maybe just with make different roles...

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


#tfsec:ignore:aws-iam-no-policy-wildcards
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
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
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
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_driftctl_actions" {
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
  policy = data.aws_iam_policy_document.github_driftctl_actions.json
}

data "aws_iam_policy_document" "github-s3-action-policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::${local.terraform_bucket_name}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.terraform_bucket_name}/${local.key}"
    ]
  }
  #tfsec:ignore:aws-iam-no-policy-wildcards
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:eu-central-1:*:table/${var.dynamodb_table_tf}"]
  }
}

resource "aws_iam_policy" "github-s3-action" {
  name        = "${var.application_name}-github-deployment-s3-terraform-state-policy"
  description = "Grant Github Actions the ability to push to terraform state s3"
  policy      = data.aws_iam_policy_document.github-s3-action-policy.json
}

resource "aws_iam_role_policy_attachment" "github-s3" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-s3-action.arn
}

resource "aws_iam_role_policy_attachment" "kms" {
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  role       = aws_iam_role.github.name
}

data "aws_iam_policy_document" "github_ssm_role_policy" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = formatlist("%s", local.arn_key_list)
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "github-ssm-action" {
  name        = "${var.application_name}-github-deployment-ssm-policy"
  description = "Grant Github Actions the ability to push to ssm the info to share"
  policy      = data.aws_iam_policy_document.github_ssm_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-ssm" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-ssm-action.arn
}
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_alb_role_policy" {
  statement {
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTags",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "github-alb-action" {
  name        = "${var.application_name}-github-deployment-alb-policy"
  description = "Grant Github Actions the ability to create alb"
  policy      = data.aws_iam_policy_document.github_alb_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-alb" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-alb-action.arn
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_ecs_role_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeServices"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "github-ecs-action" {
  name        = "${var.application_name}-github-deployment-ecs-policy"
  description = "Grant Github Actions the ability to create ecs"
  policy      = data.aws_iam_policy_document.github_ecs_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-ecs" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-ecs-action.arn
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_logs_role_policy" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "github-logs-action" {
  name        = "${var.application_name}-github-deployment-logs-policy"
  description = "Grant Github Actions the ability to create logs"
  policy      = data.aws_iam_policy_document.github_logs_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-logs" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-logs-action.arn
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_cloudfront_role_policy" {
  statement {
    actions = [
      "cloudfront:GetCloudFrontOriginAccessIdentity",
      "cloudfront:GetCachePolicy",
      "cloudfront:GetOriginRequestPolicy",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:UpdateDistribution"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "github-cloudfront-action" {
  name        = "${var.application_name}-github-deployment-cloudfront-policy"
  description = "Grant Github Actions the ability to create cloudfront"
  policy      = data.aws_iam_policy_document.github_cloudfront_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-cloudfront" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-cloudfront-action.arn
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "github_iam_role_policy" {
  statement {
    actions = [
      "iam:ListPolicyVersions",
      "iam:DetachRolePolicy"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "github-iam-action" {
  name        = "${var.application_name}-github-deployment-iam-policy"
  description = "Grant Github Actions the ability to create iam"
  policy      = data.aws_iam_policy_document.github_iam_role_policy.json
}

resource "aws_iam_role_policy_attachment" "github-iam" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github-iam-action.arn
}