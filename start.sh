#!/bin/bash
#run init vars and commands
echo "Remember use source start.sh"
saml2aws login --force
eval "$(saml2aws script)"
echo "Remember that the access is granted until $AWS_CREDENTIAL_EXPIRATION."
export AWS_DEFAULT_REGION=eu-central-1
export PATH="$HOME/.tfenv/bin:$PATH"
export TFENV_ARCH="arm64"
export TFENV_CURL_OUTPUT=2
export BASHLOG_FILE=1
export BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$}
"'
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 154603002500.dkr.ecr.eu-central-1.amazonaws.com