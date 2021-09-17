SSH_PK ?= ~/.ssh/scaleway

tf := terraform -chdir=provisioning
ansible := ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook

ansible_auth := -u root --private-key "$(SSH_PK)"
tf_vars := -var "ssh_private_key=$(SSH_PK)"

ip = $(shell $(tf) output -raw web_server_ip_address)

.PHONY: deploy provision destroy

deploy: provision
	$(ansible) -i $(ip), $(ansible_auth) deployment/playbook.yaml

provision:
	$(tf) apply -auto-approve $(tf_vars)

destroy:
	$(tf) destroy -auto-approve $(tf_vars)
