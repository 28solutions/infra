tf := terraform
tf_vars := -var "aws_profile=terraform"

.PHONY: provision plan lint

provision: .terraform
	$(tf) apply -auto-approve $(tf_vars)

plan: .terraform
	$(tf) plan $(tf_vars)

.terraform:
	$(tf) init

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
