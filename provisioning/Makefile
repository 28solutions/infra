1p_creds = . $(HOME)/.creds/terraform@1password

tf := terraform
tf_backend_config := <(op inject -i ../shared/config.s3.tfbackend)
tf_init := $(tf) init -backend-config=$(tf_backend_config)

.PHONY: all upgrade lint plan provision destroy versions

all: provision

lint:
	$(tf) fmt -recursive -check
	$(tf) validate

.terraform:
	$(1p_creds) && $(tf_init)

upgrade: .terraform
	$(1p_creds) && $(tf_init) -upgrade

plan: .terraform
	$(1p_creds) && $(tf) plan

provision: .terraform
	$(1p_creds) && $(tf) apply -auto-approve

destroy: .terraform
	$(1p_creds) && $(tf) destroy

versions:
	@echo Terraform $(shell $(tf) version -json | jq -r .terraform_version)
