cf_creds = . $(HOME)/.creds/terraform@cloudflare

tf := terraform

tf_vars := \
	-var "ssh_private_key=$(SSH_PK)" \
	-var "acme_production=true" \
	-var "acme_email_address=stephane@twentyeight.solutions"

.PHONY: all lint check-ssh-pk plan provision destroy versions

all: provision

lint:
	$(tf) fmt -recursive -check
	$(tf) validate

.terraform:
	$(tf) init -backend-config=../shared/config.s3.tfbackend

check-ssh-pk:
ifndef SSH_PK
	$(error SSH_PK is undefined)
endif

plan: check-ssh-pk .terraform
	$(cf_creds) && $(tf) plan $(tf_vars)

provision: check-ssh-pk .terraform
	$(cf_creds) && $(tf) apply -auto-approve $(tf_vars)

destroy: check-ssh-pk .terraform
	$(cf_creds) && $(tf) destroy -auto-approve $(tf_vars)

versions:
	@echo Terraform $(shell terraform version -json | jq -r .terraform_version)
