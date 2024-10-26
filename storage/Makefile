tf := terraform

.PHONY: provision lint

provision: .terraform
	$(tf) apply -auto-approve

.terraform:
	$(tf) init

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
