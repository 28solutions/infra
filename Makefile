SSH_PK ?= ~/.ssh/scaleway

cf_creds = . $(HOME)/.creds/terraform@cloudflare

tf := terraform -chdir=provisioning
tf_vars := \
	-var "ssh_private_key=$(SSH_PK)" \
	-var "acme_production=true" \
	-var "acme_email_address=stephane@twentyeight.solutions"

ansible := \
	ANSIBLE_HOST_KEY_CHECKING=False \
	.venv/bin/ansible-playbook \
	--ssh-common-args "-o ControlMaster=no -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"

ansible_auth := -u root --private-key "$(SSH_PK)"

ip = $(shell $(tf) output -raw web_server_ip_address)
ssh_port = $(shell $(tf) output -raw web_server_ssh_port)
ansible_vars = $(tf) output -json | jq -c 'map_values(.value)'

.PHONY: all lint bootstrap plan provision deploy services destroy versions

all: services

lint: provisioning/.terraform .venv
	$(MAKE) --directory bootstrap lint
	$(tf) fmt -check
	$(tf) validate
	cd deployment && ../.venv/bin/ansible-lint --profile production --strict
	$(MAKE) --directory services lint

bootstrap:
	$(MAKE) --directory bootstrap

provisioning/.terraform:
	$(tf) init

plan: provisioning/.terraform
	$(cf_creds) && $(tf) plan $(tf_vars)

provision: provisioning/.terraform
	$(cf_creds) && $(tf) apply -auto-approve $(tf_vars)

.venv:
	python -m venv --upgrade-deps .venv
	.venv/bin/pip install ansible ansible-lint

deploy: provision .venv
	$(ansible_vars) | $(ansible) -i $(ip), -e ansible_port=$(ssh_port) $(ansible_auth) deployment/playbook.yaml

services: deploy
	$(MAKE) --directory services

destroy: provisioning/.terraform
	$(MAKE) --directory services destroy
	$(cf_creds) && $(tf) destroy -auto-approve $(tf_vars)

versions: .venv
	@echo Terraform $(shell terraform version -json | jq -r .terraform_version)
	@echo Ansible $(shell .venv/bin/ansible --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell .venv/bin/ansible-lint --version | grep -Eo "[0-9.]+" | head -n 1)
