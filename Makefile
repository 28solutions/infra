.PHONY: all lint bootstrap plan detect-drift storage provision deploy services destroy upgrade versions

all: services

lint:
	$(MAKE) --directory bootstrap lint
	$(MAKE) --directory storage lint
	$(MAKE) --directory provisioning lint
	$(MAKE) --directory deployment lint
	$(MAKE) --directory services lint

bootstrap:
	$(MAKE) --directory bootstrap

plan:
	$(MAKE) --directory bootstrap plan
	$(MAKE) --directory storage plan
	$(MAKE) --directory provisioning plan
	$(MAKE) --directory deployment plan
	$(MAKE) --directory services plan

detect-drift:
	$(MAKE) --directory bootstrap plan tf_plan_params=-detailed-exitcode
	$(MAKE) --directory storage plan tf_plan_params=-detailed-exitcode
	$(MAKE) --directory provisioning plan tf_plan_params=-detailed-exitcode
	$(MAKE) --directory deployment plan | sed '/changed=0.*failed=0/,$$b;$$q1'
	$(MAKE) --directory services plan tf_plan_params=-detailed-exitcode

storage: bootstrap
	$(MAKE) --directory storage

provision: bootstrap
	$(MAKE) --directory provisioning

deploy: provision storage
	$(MAKE) --directory deployment

services: bootstrap deploy storage
	$(MAKE) --directory services

destroy:
	$(MAKE) --directory services destroy
	$(MAKE) --directory provisioning destroy

upgrade:
	$(MAKE) --directory bootstrap upgrade
	$(MAKE) --directory storage upgrade
	$(MAKE) --directory provisioning upgrade
	$(MAKE) --directory deployment upgrade
	$(MAKE) --directory services upgrade

versions:
	@$(MAKE) --no-print-directory --directory provisioning versions
	@$(MAKE) --no-print-directory --directory deployment versions
