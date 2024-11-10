1p_creds = . $(HOME)/.creds/terraform@1password

tf := terraform
tf_backend_config := <(op inject -i ../shared/config.s3.tfbackend)
tf_init := $(tf) init -backend-config=$(tf_backend_config)

.PHONY: provision plan upgrade lint

provision: .terraform
	$(tf) apply -auto-approve

plan: .terraform
	$(tf) plan

.terraform:
	$(1p_creds) && $(tf_init)

upgrade: .terraform
	$(1p_creds) && $(tf_init) -upgrade

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate
