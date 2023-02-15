#!/bin/bash
#run init vars and commands
echo "Remember use source start_dry.sh"
eval "$(saml2aws script)"
echo "Remember the access is granted until $AWS_CREDENTIAL_EXPIRATION."
export AWS_DEFAULT_REGION=eu-central-1
export PATH="$HOME/.tfenv/bin:$PATH"
export TFENV_ARCH="arm64"
export TFENV_CURL_OUTPUT=2
export BASHLOG_FILE=1
export BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$}
"'