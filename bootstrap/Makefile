tf := terraform
tf_vars := -var "aws_profile=terraform"

.PHONY: provision lint

provision: .terraform
	$(tf) apply -auto-approve $(tf_vars)

.terraform:
	$(tf) init

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
