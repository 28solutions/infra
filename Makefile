SHELL := /bin/bash

.PHONY: all bootstrap provision storage deploy services for-each init lint plan detect-drift upgrade versions

all: services

bootstrap:
	$(MAKE) --directory bootstrap

provision: bootstrap
	$(MAKE) --directory provisioning

storage: bootstrap
	$(MAKE) --directory storage

deploy: provision storage
	$(MAKE) --directory deployment

services: bootstrap provision storage deploy
	$(MAKE) --directory services

for-each:
	$(MAKE) --directory bootstrap $(MAKECMDGOALS)
	$(MAKE) --directory storage $(MAKECMDGOALS)
	$(MAKE) --directory provisioning $(MAKECMDGOALS)
	$(MAKE) --directory deployment $(MAKECMDGOALS)
	$(MAKE) --directory services $(MAKECMDGOALS)

init: for-each

lint: for-each

plan: for-each

detect-drift: for-each

upgrade: for-each

versions:
	@$(MAKE) --no-print-directory --directory provisioning versions
	@$(MAKE) --no-print-directory --directory deployment versions
