tf := terraform

.PHONY: provision lint

provision: .terraform
	$(tf) apply -auto-approve

.terraform:
	$(tf) init -backend-config=../shared/config.s3.tfbackend

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
