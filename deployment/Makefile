ansible := ansible
ansible_pb := ansible-playbook
ansible_lint := ansible-lint

activate_venv := . .venv/bin/activate

tf_provisioning := terraform -chdir=../provisioning
tf_storage := terraform -chdir=../storage

ip := $(shell $(tf_provisioning) output -raw web_server_ip_address)
ssh_port := $(shell $(tf_provisioning) output -raw web_server_ssh_port)
ansible_vars := $(tf_provisioning) output -json | jq -c 'map_values(.value)'
pki_domain_name := $(shell $(tf_storage) output -raw pki_domain_name)

ansible_env = ANSIBLE_HOST_KEY_CHECKING=False
ansible_inventory := -i $(ip), -e ansible_port=$(ssh_port)
ansible_auth := -u root --private-key "$(SSH_PK)"
ansible_ssh_opts := \
	--ssh-common-args "-o ControlMaster=no -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"
ansible_extra_vars := --extra-vars "pki_domain_name=$(pki_domain_name)"

.PHONY: all lint plan deploy check-ssh-pk versions

all: deploy

lint: .venv
	$(activate_venv) && $(ansible_lint) --profile production --strict

plan:
	$(MAKE) deploy SSH_PK=$(SSH_PK) ansible_pb="$(ansible_pb) --check --diff"

deploy: check-ssh-pk .venv
	$(activate_venv) && $(ansible_vars) | \
		$(ansible_env) $(ansible_pb) \
			$(ansible_ssh_opts) \
			$(ansible_inventory) \
			$(ansible_auth) \
			$(ansible_extra_vars) \
			playbook.yaml

check-ssh-pk:
ifndef SSH_PK
	$(error SSH_PK is undefined)
endif

.venv:
	python -m venv --upgrade-deps .venv
	$(activate_venv) && pip install ansible ansible-lint

versions: .venv
	@echo Ansible $(shell $(activate_venv) && $(ansible) --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell $(activate_venv) && $(ansible_lint) --version | grep -Eo "[0-9.]+" | head -n 1)
