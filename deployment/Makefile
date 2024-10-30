ansible_pb := .venv/bin/ansible-playbook

ansible_cmd := \
	ANSIBLE_HOST_KEY_CHECKING=False \
	$(ansible_pb) \
	--ssh-common-args "-o ControlMaster=no -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"

ansible_auth := -u root --private-key "$(SSH_PK)"

tf := terraform -chdir=../provisioning

ip = $(shell $(tf) output -raw web_server_ip_address)
ssh_port = $(shell $(tf) output -raw web_server_ssh_port)
ansible_vars = $(tf) output -json | jq -c 'map_values(.value)'

.PHONY: all lint plan deploy check-ssh-pk versions

all: deploy

lint: .venv
	.venv/bin/ansible-lint --profile production --strict

plan:
	$(MAKE) deploy SSH_PK=$(SSH_PK) ansible_pb="$(ansible_pb) --check --diff"

deploy: check-ssh-pk .venv
	$(ansible_vars) | $(ansible_cmd) -i $(ip), -e ansible_port=$(ssh_port) $(ansible_auth) playbook.yaml

check-ssh-pk:
ifndef SSH_PK
	$(error SSH_PK is undefined)
endif

.venv:
	python -m venv --upgrade-deps .venv
	.venv/bin/pip install ansible ansible-lint

versions: .venv
	@echo Ansible $(shell .venv/bin/ansible --version | grep -Po '(?<=core )[0-9.]+')
	@echo Ansible Lint $(shell .venv/bin/ansible-lint --version | grep -Eo "[0-9.]+" | head -n 1)
