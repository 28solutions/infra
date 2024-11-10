1p_creds = . $(HOME)/.creds/terraform@1password

tf := terraform
tf_backend_config := <(op inject -i ../shared/config.s3.tfbackend)
tf_init := $(tf) init -backend-config=$(tf_backend_config)

.PHONY: provision plan upgrade lint destroy

provision: .terraform
	$(1p_creds) && $(tf) apply -auto-approve -var-file=$(tf_backend_config)

plan: .terraform
	$(1p_creds) && $(tf) plan -var-file=$(tf_backend_config)

.terraform:
	$(1p_creds) && $(tf_init)

upgrade: .terraform
	$(1p_creds) && $(tf_init) -upgrade

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate

destroy: .terraform
	$(1p_creds) && $(tf) destroy
