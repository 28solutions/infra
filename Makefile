SSH_PK ?= ~/.ssh/scaleway

.PHONY: all lint bootstrap plan storage provision deploy services destroy versions

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
	$(MAKE) --directory provisioning plan SSH_PK=$(SSH_PK)
	$(MAKE) --directory deployment plan SSH_PK=$(SSH_PK)
	$(MAKE) --directory services plan

storage:
	$(MAKE) --directory storage

provision:
	$(MAKE) --directory provisioning SSH_PK=$(SSH_PK)

deploy: provision storage
	$(MAKE) --directory deployment SSH_PK=$(SSH_PK)

services: deploy storage
	$(MAKE) --directory services

destroy:
	$(MAKE) --directory services destroy
	$(MAKE) --directory provisioning destroy

versions:
	$(MAKE) --directory provisioning versions
	$(MAKE) --directory deployment versions
