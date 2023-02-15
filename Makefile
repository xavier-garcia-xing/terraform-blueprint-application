# USAGE
define USAGE
Usage: make [help | install | lint | fmt | compliance env=[environment] | plan env=[environment] | apply env=[environment] | destroy env=[environment]]
endef
export USAGE

define USAGE_SETUP
Usage: make [help | install | lint | fmt | compliance_setup env=[environment] | plan_setup env=[environment] | apply_setup env=[environment] | destroy_setup env=[environment]]
endef
export USAGE_SETUP

TF_DIR := ./terraform
UNAME := $(shell uname -s)

help:
	@echo "$$USAGE"

install:
	tfenv install
	tgenv install

lint:
	./scripts/lint.sh

fmt:
	./scripts/fmt.sh

compliance:
	./scripts/compliance.sh $(env)

init:
	./scripts/init.sh $(env)

plan: init
	./scripts/plan.sh $(env)

apply:
	./scripts/apply.sh $(env)

destroy:
	./scripts/destroy.sh $(env)

help_setup:
	@echo "$$USAGE_SETUP"

compliance_setup:
	./scripts/compliance.sh $(env)

init_setup:
	./scripts/init.sh $(env)_setup

plan_setup: init
	./scripts/plan.sh $(env)_setup

apply_setup:
	./scripts/apply.sh $(env)_setup

destroy_setup:
	./scripts/destroy.sh $(env)_setup
