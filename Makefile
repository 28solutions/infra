SSH_PK ?= ~/.ssh/scaleway

.PHONY: all lint bootstrap plan storage provision deploy services destroy upgrade versions

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
	$(MAKE) --directory storage plan
	$(MAKE) --directory provisioning plan
	$(MAKE) --directory deployment plan SSH_PK=$(SSH_PK)
	$(MAKE) --directory services plan

storage:
	$(MAKE) --directory storage

provision:
	$(MAKE) --directory provisioning

deploy: provision storage
	$(MAKE) --directory deployment SSH_PK=$(SSH_PK)

services: deploy storage
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
