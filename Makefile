SSH_PK ?= ~/.ssh/scaleway

cf_creds = . $(HOME)/.creds/terraform@cloudflare

tf := terraform -chdir=provisioning
tf_vars := \
	-var "ssh_private_key=$(SSH_PK)" \
	-var "acme_production=true" \
	-var "acme_email_address=stephane@twentyeight.solutions"

.PHONY: all lint bootstrap storage plan provision deploy services destroy versions

all: storage services

lint: provisioning/.terraform
	$(MAKE) --directory bootstrap lint
	$(MAKE) --directory storage lint
	$(tf) fmt -recursive -check
	$(tf) validate
	$(MAKE) --directory deployment lint
	$(MAKE) --directory services lint

bootstrap:
	$(MAKE) --directory bootstrap

storage:
	$(MAKE) --directory storage

provisioning/.terraform:
	$(tf) init -backend-config=../shared/config.s3.tfbackend

plan: provisioning/.terraform
	$(cf_creds) && $(tf) plan $(tf_vars)

provision: provisioning/.terraform
	$(cf_creds) && $(tf) apply -auto-approve $(tf_vars)

deploy: provision
	$(MAKE) --directory deployment SSH_PK=$(SSH_PK)

services: deploy
	$(MAKE) --directory services

destroy: provisioning/.terraform
	$(MAKE) --directory services destroy
	$(cf_creds) && $(tf) destroy -auto-approve $(tf_vars)

versions:
	@echo Terraform $(shell terraform version -json | jq -r .terraform_version)
	$(MAKE) --directory deployment versions
