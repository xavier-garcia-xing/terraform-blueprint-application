#!/bin/bash

# usage: ./plan.sh <ENVIRONMENT>

set -euo pipefail

# change to parent directory of this script so the context is correct
cd $(dirname $(dirname "$0"))

# interpret first argument as environment to set working directory
terragrunt_environment=$1

TF_CLI_ARGS=${TF_CLI_ARGS:-}

if [[ "$terragrunt_environment" != production ]]; then
  TF_CLI_ARGS="-lock=false ${TF_CLI_ARGS}"
fi

terragrunt plan ${TF_CLI_ARGS} -out=tfplan.binary \
        --terragrunt-working-dir=environments/$terragrunt_environment
