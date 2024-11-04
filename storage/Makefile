tf := terraform
tf_init := $(tf) init -backend-config=../shared/config.s3.tfbackend

.PHONY: provision plan upgrade lint

provision: .terraform
	$(tf) apply -auto-approve

plan: .terraform
	$(tf) plan

.terraform:
	$(tf_init)

upgrade: .terraform
	$(tf_init) -upgrade

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
