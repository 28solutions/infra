tf := terraform

.PHONY: provision lint destroy

provision: .terraform
	$(tf) apply -auto-approve

.terraform:
	$(tf) init

lint: .terraform
	$(tf) fmt -check
	$(tf) validate

destroy: .terraform
	$(tf) destroy -auto-approve
