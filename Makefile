SSH_PK ?= ~/.ssh/scaleway

cf_creds = . $(HOME)/.creds/terraform@cloudflare

tf := terraform -chdir=provisioning
tf_vars := \
	-var "ssh_private_key=$(SSH_PK)" \
	-var "acme_production=false" \
	-var "acme_email_address=stephane@twentyeight.solutions"

ansible := ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook
ansible_auth := -u root --private-key "$(SSH_PK)"

ip = $(shell $(tf) output -raw web_server_ip_address)
ssh_port = $(shell $(tf) output -raw web_server_ssh_port)
ansible_vars = $(tf) output -json | jq -c 'map_values(.value)'

.PHONY: all lint bootstrap plan provision deploy destroy versions

all: deploy

lint: provisioning/.terraform
	$(MAKE) --directory bootstrap lint
	$(tf) fmt -check
	$(tf) validate
	cd deployment && ansible-lint

bootstrap:
	$(MAKE) --directory bootstrap

provisioning/.terraform:
	$(tf) init

plan: provisioning/.terraform
	$(cf_creds) && $(tf) plan $(tf_vars)

provision: provisioning/.terraform
	$(cf_creds) && $(tf) apply -auto-approve $(tf_vars)

deploy: provision
	$(ansible_vars) | $(ansible) -i $(ip), -e ansible_port=$(ssh_port) $(ansible_auth) deployment/playbook.yaml

destroy: provisioning/.terraform
	$(cf_creds) && $(tf) destroy -auto-approve $(tf_vars)

versions:
	@echo Terraform $(shell terraform version -json | jq -r .terraform_version)
	@echo Ansible $(shell ansible --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell ansible-lint --version | grep -Eo "[0-9.]+" | head -n 1)
