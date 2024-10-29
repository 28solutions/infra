tf := terraform
tf_backend_config := config.s3.tfbackend

.PHONY: provision lint destroy

provision: .terraform
	$(tf) apply -auto-approve

plan: .terraform
	$(tf) plan

.terraform:
	$(tf) init -backend-config=$(tf_backend_config)

lint: .terraform
	$(tf) fmt -recursive -check
	$(tf) validate

destroy: .terraform
	$(tf) destroy -auto-approve
