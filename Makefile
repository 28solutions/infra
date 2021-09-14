.PHONY: provision

provision:
	terraform -chdir=provisioning apply -auto-approve -var "ssh_private_key=$(SSH_PK)"
