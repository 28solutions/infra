SSH_PK ?= ~/.ssh/scaleway

tf := terraform -chdir=provisioning
tf_vars := -var "ssh_private_key=$(SSH_PK)"

ansible := ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook
ansible_auth := -u root --private-key "$(SSH_PK)"

ip = $(shell $(tf) output -raw web_server_ip_address)

.PHONY: bootstrap deploy provision destroy versions

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

provision: provisioning/.terraform
	$(tf) apply -auto-approve $(tf_vars)

deploy: provision
	$(ansible) -i $(ip), $(ansible_auth) deployment/playbook.yaml

destroy: provisioning/.terraform
	$(tf) destroy -auto-approve $(tf_vars)

versions:
	@echo Terraform $(shell terraform version -json | jq -r .terraform_version)
	@echo Ansible $(shell ansible --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell ansible-lint --version | grep -Eo "[0-9.]+" | head -n 1)
