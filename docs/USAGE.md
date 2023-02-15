# Usage

## Scripts

For more detailed information, head over to [terraform commands docu](https://www.terraform.io/cli/commands).

### Makefile

A bunch of scripts, help you to interact with terraform, you can find them in `scripts`.

To get an idea what you can do, use:
```sh
make help
```

#### Compliance check
In order to run compliance checks locally, you first need to login to ECR: 
````sh
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 154603002500.dkr.ecr.eu-central-1.amazonaws.com
````

:bulb: in general, we strongly advice to interact with terraform locally **only in sandbox** environments. With all
other environments you should consider to interact via pipeline only. This suggestion is in alignment with the
[GitOps](https://about.gitlab.com/topics/gitops/) principles, that are proven in the context of infrastructure as code.

## Automation

This repo comes with an opinionated CI/CD pipline based on [github actions](https://docs.github.com/en/actions).
The pipeline supports:
* linting -> improve code quality
* auditing -> meet our compliance rules and guardrails
* deployment -> bring your changes automatically live
* drift detection -> check if your account has any configuration drifts from your infrastructure

See [automate Terraform](https://learn.hashicorp.com/tutorials/terraform/automate-terraform).

### Setup CI/CD for your project based on this Blueprint

#### Prerequisites

1. Your Repository must be hosted on [github.com](https://github.com)
2. You need to setup an OIDC IDP in every AWS account that is a target for deployments ([see](https://confluence.xing.hh/x/Y4jUIQ))
3. You need an  IAM role in the respective AWS accounts with sufficient permissions to execute Terraform (aka. formerly known as technical terraform user)
   * at least this role needs access to the S3 remote state ([see](https://www.terraform.io/language/settings/backends/s3#s3-bucket-permissions)) and DynamoDB table ([see](https://www.terraform.io/language/settings/backends/s3#dynamodb-table-permissions))

#### Configure deployment

1. Check if [deployment](../.github/workflows/deploy.yml) meets your requirements
2. Set the corresponding values for `<TARGET_ACCOUNT_ID>`

#### Configure drift detection

1. Create an IAM role in the target AWS account with the name `nw-driftctl`
2. Attach the managed policy `ReadOnlyAccess`
3. Configure the workflow for [driftctl](../.github/workflows/driftctl.yml)

### Dependency management

We encourage you to use Github native [Dependabot](https://github.com/dependabot/dependabot-core) or
[Renovate](https://www.mend.io/free-developer-tools/renovate/) to keep your codebase up to date. We **recommend** Renovate
over Dependabot since it is far more flexible and 100% compatible with this template repository. However Renovate is not
available out-of-the box and needs to be enabled manually per repository.

## Structure

This template comes with an opinionated folder structure, but you are free to change on your behalf.

```
terraform-blueprint
│   README.md
│   Makefile, etc
│
└───environments
│    │
│    └───sandbox
│    │       terragrunt.hcl --> configuration for sandbox environment
│    │
│    └───preview
│    │       terragrunt.hcl --> configuration for staging environment
│    │
│    └───production
│            terragrunt.hcl --> configuration for production environment
│
└───terraform
│        *.tf --> the actual terraform config files
│
└───scripts
│        *.sh --> utility scripts
│
└───docs
│        *.md --> documentation
│
└───.github
        └───workflows
                *.yml --> Github pipeline workflows
```

### Add another environment

To add another environment, simply add another folder under `environment/`. The folder name equals the name of the
environment. You need to put a `terragrunt.hcl` file for terragrunt in the respective folder. Mind to **update** the
settings according to your environments requirements.
:chocolate_bar: That's it!
