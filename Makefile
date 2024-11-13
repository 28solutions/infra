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
	$(MAKE) --directory bootstrap detect-drift
	$(MAKE) --directory storage detect-drift
	$(MAKE) --directory provisioning detect-drift
	$(MAKE) --directory deployment detect-drift
	$(MAKE) --directory services detect-drift

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
