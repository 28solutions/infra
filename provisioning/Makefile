cf_creds = . $(HOME)/.creds/terraform@cloudflare
1p_creds = . $(HOME)/.creds/terraform@1password

tf := terraform
tf_init := $(tf) init -backend-config=../shared/config.s3.tfbackend

tf_vars := -var "ssh_private_key=$(SSH_PK)"

.PHONY: all upgrade lint check-ssh-pk plan provision destroy versions

all: provision

lint:
	$(tf) fmt -recursive -check
	$(tf) validate

.terraform:
	$(tf_init)

upgrade: .terraform
	$(tf_init) -upgrade

check-ssh-pk:
ifndef SSH_PK
	$(error SSH_PK is undefined)
endif

plan: check-ssh-pk .terraform
	$(cf_creds) && $(1p_creds) && $(tf) plan $(tf_vars)

provision: check-ssh-pk .terraform
	$(cf_creds) && $(1p_creds) && $(tf) apply -auto-approve $(tf_vars)

destroy: check-ssh-pk .terraform
	$(cf_creds) && $(1p_creds) && $(tf) destroy $(tf_vars)

versions:
	@echo Terraform $(shell $(tf) version -json | jq -r .terraform_version)
