.PHONY: deploy provision destroy

tf := terraform -chdir=provisioning
ansible := ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook

ip = $(shell $(tf) output -raw web_server_ip_address)

deploy: provision
	$(ansible) -u root -i $(ip), --private-key '$(SSH_PK)' deployment/playbook.yaml

provision:
	$(tf) apply -auto-approve -var "ssh_private_key=$(SSH_PK)"

destroy:
	$(tf) destroy -auto-approve -var "ssh_private_key=$(SSH_PK)"
