SHELL := /bin/bash

has_1p_creds := 0

ifdef OP_SERVICE_ACCOUNT_TOKEN
	has_1p_creds := 1
endif

ifdef OP_CONNECT_HOST
ifdef OP_CONNECT_TOKEN
	has_1p_creds := 1
endif
endif

ifeq ($(has_1p_creds),0)
	1p_creds = . $(HOME)/.creds/terraform@1password &&
endif

ansible := ansible
ansible_galaxy := ansible-galaxy
ansible_pb := ansible-playbook
ansible_lint := ansible-lint

color ?= 1

activate_venv := . .venv/bin/activate

tf_provisioning := terraform -chdir=../provisioning
tf_storage := terraform -chdir=../storage

ip = $(shell $(tf_provisioning) output -raw web_server_ip_address)
ssh_port = $(shell $(tf_provisioning) output -raw web_server_ssh_port)
ansible_vars = $(tf_provisioning) output -json | jq -c 'map_values(.value)'
pki_domain_name = $(shell $(tf_storage) output -raw pki_domain_name)

ifeq ($(color),0)
	ansible_env := $(ansible_env) ANSIBLE_NOCOLOR=True
else
	ansible_env := $(ansible_env) ANSIBLE_FORCE_COLOR=True
endif

ansible_env := $(ansible_env) ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_PIPELINING=True
ansible_inventory = -i $(ip), -e ansible_port=$(ssh_port)
ansible_auth = -u root
ansible_ssh_opts = \
	--ssh-common-args "-o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"
ansible_extra_vars = --extra-vars "pki_domain_name=$(pki_domain_name)"
ansible_pb_path := playbook.yaml

ansible_galaxy_install_parameters = --force --role-file requirements.yaml
ansible_galaxy_install = $(ansible_galaxy) install $(ansible_galaxy_install_parameters)

.PHONY: all lint plan detect-drift deploy apt-upgrade upgrade versions

all: deploy

ifndef VIRTUAL_ENV
lint: .venv
	$(activate_venv) && $(MAKE) lint
else
lint:
	$(ansible_galaxy_install)
	$(ansible_lint) --profile production --strict
endif

plan:
	$(MAKE) deploy ansible_pb="$(ansible_pb) --check --diff"

detect-drift:
	$(MAKE) plan | sed '/changed=0.*failed=0/,$$b;$$q1'

ifndef VIRTUAL_ENV
deploy: .venv
	$(activate_venv) && $(MAKE) deploy
else ifndef SSH_AUTH_SOCK
deploy:
	ssh-agent $(MAKE) deploy
else
deploy:
	$(ansible_galaxy_install)
	$(1p_creds) op read 'op://IaC/Scaleway SSH key/private key' | ssh-add -
	$(1p_creds) \
		$(ansible_env) $(ansible_pb) \
			$(ansible_ssh_opts) \
			$(ansible_inventory) \
			$(ansible_auth) \
			$(ansible_extra_vars) \
			--extra-vars "tf_vars_cmd=\"$(ansible_vars)\"" \
			$(ansible_pb_path)
endif

apt-upgrade:
	$(MAKE) deploy ansible_pb_path=upgrade.yaml

.venv:
	python -m venv --upgrade-deps .venv
	$(activate_venv) && pip install ansible ansible-lint

init: .venv

upgrade: .venv
	$(activate_venv) && pip install --upgrade pip ansible ansible-lint

ifndef VIRTUAL_ENV
versions: .venv
	@$(activate_venv) && $(MAKE) --no-print-directory versions
else
versions:
	@echo Ansible $(shell $(ansible) --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell $(ansible_lint) --version | grep -Eo "[0-9.]+" | head -n 1)
endif
