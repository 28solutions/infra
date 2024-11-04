tf := terraform
tf_backend_config := ../shared/config.s3.tfbackend
tf_init := $(tf) init

.PHONY: provision plan upgrade lint

provision: .terraform
	$(tf) apply -auto-approve -var-file=$(tf_backend_config)

plan: .terraform
	$(tf) plan -var-file=$(tf_backend_config)

.terraform:
	$(tf_init)

upgrade: .terraform
	$(tf_init) -upgrade

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
