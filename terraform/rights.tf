/*#document all file terraform code
 module "github_auth" {
    resource "aws_iam_openid_connect_provider" "github" {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
    }


    data "aws_iam_policy_document" "github_actions_assume_role" {
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
        #it have to 
        values = [
           "repo:source.xing.com:xavier-garcia/blue-print-poc1:*",
        ]
        }
    }
    }


    resource "aws_iam_role" "github_actions" {
    name               = "github-actions"
    assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
    max_session_duration = 3600
    }


    data "aws_iam_policy_document" "github_actions" {
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

    resource "aws_iam_policy" "github_actions" {
    name        = "github-actions"
    description = "Grant Github Actions the ability to push to ECR"
    policy      = data.aws_iam_policy_document.github_actions.json
    }

    resource "aws_iam_role_policy_attachment" "github_actions" {
    role       = aws_iam_role.github_actions.name
    policy_arn = aws_iam_policy.github_actions.arn
    }

    resource "aws_ecr_repository" "repo" {
    name                 = "c/repository"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    tag = {
        "permit-github-action" = true
    }
    }
 }
 */