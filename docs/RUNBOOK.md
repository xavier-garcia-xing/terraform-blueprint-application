# Runbook

## Logs

### How to download access logs from S3

```sh
aws --profile saml --region eu-central-1 s3 cp s3://nw-bucket-terraform-with-terragrunt-sandbox-website-access-log/log access_log --recursive --exclude "*" --include "<cloudfront_id>.<date>*"
```

#### Example

```sh
aws --profile saml --region eu-central-1 s3 cp s3://nw-bucket-terraform-with-terragrunt-sandbox-website-access-log/log access_log --recursive --exclude "*" --include "EWMGEXPC97Q4M.2022-01-17*"
```

## Metrics
