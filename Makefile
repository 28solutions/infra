SSH_PK ?= ~/.ssh/scaleway

tf := terraform -chdir=provisioning
tf_vars := -var "ssh_private_key=$(SSH_PK)"

ansible := ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook
ansible_auth := -u root --private-key "$(SSH_PK)"

ip = $(shell $(tf) output -raw web_server_ip_address)

.PHONY: deploy provision destroy

all: deploy

provisioning/.terraform:
	$(tf) init

provision: provisioning/.terraform
	$(tf) apply -auto-approve $(tf_vars)

deploy: provision
	$(ansible) -i $(ip), $(ansible_auth) deployment/playbook.yaml

destroy: provisioning/.terraform
	$(tf) destroy -auto-approve $(tf_vars)
