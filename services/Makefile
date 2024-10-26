tf := terraform

.PHONY: provision lint destroy

provision: .terraform
	$(tf) apply -auto-approve

plan: .terraform
	$(tf) plan

.terraform:
	$(tf) init

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate

destroy: .terraform
	$(tf) destroy -auto-approve
