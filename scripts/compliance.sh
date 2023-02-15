#!/bin/bash

# usage: ./conftest.sh <ENVIRONMENT>

set -euo pipefail

# change to parent directory of this script so the context is correct
cd $(dirname $(dirname "$0"))

# interpret first argument as environment to set working directory
environment=$1

TERRAFORM_SRC_DIR=$(find environments/${environment} -name terraform)
current_dir=$PWD

cd ${TERRAFORM_SRC_DIR}

if [ -f "tfplan.binary" ]; then
    echo "transforming terraform plan"
    terraform show -json tfplan.binary > tfplan.json
    echo "starting analysis"
    conftest test --update 154603002500.dkr.ecr.eu-central-1.amazonaws.com/cpt/compliance-bundle//policies tfplan.json --data policy/config/data -n terraform
else
    echo "You need to run './script/plan.sh ${environment}' first, aborting..."
    exit 1;
fi

echo "Done with $(basename $0)"

cd ${current_dir}