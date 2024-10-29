tf := terraform

.PHONY: provision plan lint

provision: .terraform
	$(tf) apply -auto-approve

plan: .terraform
	$(tf) plan

.terraform:
	$(tf) init -backend-config=../shared/config.s3.tfbackend

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
