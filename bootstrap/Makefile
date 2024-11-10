1p_creds = . $(HOME)/.creds/terraform@1password

tf := terraform
tf_backend_config := <(op inject -i ../shared/config.s3.tfbackend)
tf_init := $(tf) init

.PHONY: provision plan upgrade lint

provision: .terraform
	$(1p_creds) && $(tf) apply -auto-approve -var-file=$(tf_backend_config)

plan: .terraform
	$(1p_creds) && $(tf) plan -var-file=$(tf_backend_config)

.terraform:
	$(tf_init)

upgrade: .terraform
	$(tf_init) -upgrade

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
