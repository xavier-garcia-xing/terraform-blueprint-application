# Terraform blueprint

![linter](https://github.com/new-work/terraform-blueprint/actions/workflows/lint.yml/badge.svg?branch=main)
![security](https://github.com/new-work/terraform-blueprint/actions/workflows/tfsec.yml/badge.svg?branch=main)

Our goal is to describe our infrastructure using code only and configure it accordingly for each environment
using [Terraform](https://www.terraform.io/) together with [Terragrunt](https://terragrunt.gruntwork.io/).

## AWS accounts

| Environment    | Type       | Account ID   | Account alias      |
| -------------- | ---------- | ------------ | ------------------ |
| `production`       | production | `53********85`  | `*********-prod`          |
| `preview`       | staging    | `99********45`  | `*********-dev`          |

## Preparation

### Login to AWS

Use our [Single Sign-On](https://cloud.nwse.io/how-to/getting-started/login.html) to login to AWS Management Console.

### Setup

#### With Homebrew

We provide a [Brewfile](./Brewfile) for all necessary dependencies:

```sh
brew bundle && make install
```

#### Linux - without Homebrew

You need the following tools:
* [saml2aws](https://github.com/Versent/saml2aws) - AWS credentials utility
* [tfenv](https://github.com/tfutils/tfenv) - Terraform version manager
* [tgenv](https://github.com/cunymatthieu/tgenv) - Terragrunt version manager

Get the correct versions of Terraform and Terragrunt defined in `.terraform.version`/ `.terragrunt.version`:

```sh
make install
```

### Configuration

#### Saml2AWS

We use [saml2aws](https://github.com/Versent/saml2aws) to retrieve temporary credentials to access AWS resources. Find detailed information about the required setup [on Confluence](https://confluence.xing.hh/pages/viewpage.action?spaceKey=xingoperations&title=Getting+started+with+AWS#GettingstartedwithAWS-AWSCLI).

```sh
saml2aws login
```

## Usage

Have a look at [USAGE.md](./docs/USAGE.md) for project usage.

## Runbook

Have a look at [RUNBOOK.md](./docs/RUNBOOK.md) for standard operating procedures.

## Terraform

### Best practices

[Terraform best practices](https://www.terraform-best-practices.com/) is a good source for examples how to do things, especially [key concepts](https://www.terraform-best-practices.com/key-concepts#infrastructure-module) how to structure your modules.

### Naming resources

These are our [recommendations how to name resources](https://source.xing.com/cloudcuckooland/aws-naming-convention) at New Work.

## About

:raising_hand: **this repo only exists as mirror on source.xing.com the actual truth is on [github.com](https://github.com/new-work/terraform-blueprint)**

### Constraints

Please take these constraints into account when you manage our infrastructure as code.

- Use a dedicated AWS account for each [environment of a workload](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/workloads-and-environments.html)
- For CI using GitHub Action you need to host on github.com and have an OIDC provider [provisioned in your
AWS account](https://confluence.xing.hh/display/xingoperations/Github+Actions%2C+Terraform+and+AWS+credentials)

### Limitations

- At Tech Core we are evalutaing GitHub Actions and there is no offical support at this point in time
- You can make use of GitHub Action for Infrastructure as Code CI pipelines by request upon approval

Find more information about Github Actions service offering and its limitations [here](https://confluence.xing.hh/pages/viewpage.action?spaceKey=xingoperations&title=Service+Offering%3A+Github.com#ServiceOffering:Github.com-GitHubActions).

## Contribution

Feedback is always welcome :rainbow: Feel free to open an Issue (Bug- /Feature-Request)
or provide a Pull request. We will take care soon :wrench:
