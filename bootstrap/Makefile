tf := terraform
tf_vars := -var "aws_profile=terraform"

.PHONY: provision

provision: .terraform
	$(tf) apply -auto-approve $(tf_vars)

.terraform:
	$(tf) init
