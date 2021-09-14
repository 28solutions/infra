.PHONY: deploy provision

ip != terraform -chdir=provisioning output -raw web_server_ip_address

deploy: provision
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i $(ip), --private-key '$(SSH_PK)' deployment/playbook.yaml

provision:
	terraform -chdir=provisioning apply -auto-approve -var "ssh_private_key=$(SSH_PK)"
