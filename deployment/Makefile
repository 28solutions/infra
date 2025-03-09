SHELL := /bin/bash

ifndef OP_SERVICE_ACCOUNT_TOKEN
	1p_creds = . $(HOME)/.creds/terraform@1password &&
endif

ansible := ansible
ansible_pb := ansible-playbook
ansible_lint := ansible-lint

activate_venv := . .venv/bin/activate

tf_provisioning := terraform -chdir=../provisioning
tf_storage := terraform -chdir=../storage

ip = $(shell $(tf_provisioning) output -raw web_server_ip_address)
ssh_port = $(shell $(tf_provisioning) output -raw web_server_ssh_port)
ansible_vars = $(tf_provisioning) output -json | jq -c 'map_values(.value)'
pki_domain_name = $(shell $(tf_storage) output -raw pki_domain_name)

ansible_env = ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_PIPELINING=True
ansible_inventory = -i $(ip), -e ansible_port=$(ssh_port)
ansible_auth = -u root
ansible_ssh_opts = \
	--ssh-common-args "-o ControlMaster=auto -o ControlPersist=60s -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"
ansible_tags = --skip-tags upgrade
ansible_extra_vars = --extra-vars "pki_domain_name=$(pki_domain_name)"

.PHONY: all lint plan detect-drift deploy upgrade versions

all: deploy

lint: .venv
	$(activate_venv) && $(ansible_lint) --profile production --strict

plan:
	$(MAKE) deploy ansible_pb="$(ansible_pb) --check --diff"

detect-drift:
	$(MAKE) plan | sed '/changed=0.*failed=0/,$$b;$$q1'

ifndef SSH_AUTH_SOCK
deploy:
	ssh-agent $(MAKE) deploy
else
deploy: .venv
	$(1p_creds) op read 'op://IaC/Scaleway SSH key/private key' | ssh-add -
	$(activate_venv) && $(1p_creds) $(ansible_vars) | \
		$(ansible_env) $(ansible_pb) \
			$(ansible_ssh_opts) \
			$(ansible_inventory) \
			$(ansible_auth) \
			$(ansible_tags) \
			$(ansible_extra_vars) \
			playbook.yaml
endif

apt-upgrade:
	$(MAKE) deploy ansible_tags="--tags upgrade"

.venv:
	python -m venv --upgrade-deps .venv
	$(activate_venv) && pip install ansible ansible-lint

init: .venv

upgrade: .venv
	$(activate_venv) && pip install --upgrade ansible ansible-lint

versions: .venv
	@echo Ansible $(shell $(activate_venv) && $(ansible) --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell $(activate_venv) && $(ansible_lint) --version | grep -Eo "[0-9.]+" | head -n 1)
