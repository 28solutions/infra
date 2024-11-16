SHELL := /bin/bash

.PHONY: all for-each init lint bootstrap plan detect-drift storage provision deploy services upgrade versions

all: services

for-each:
	$(MAKE) --directory bootstrap $(MAKECMDGOALS)
	$(MAKE) --directory storage $(MAKECMDGOALS)
	$(MAKE) --directory provisioning $(MAKECMDGOALS)
	$(MAKE) --directory deployment $(MAKECMDGOALS)
	$(MAKE) --directory services $(MAKECMDGOALS)

init: for-each

lint: for-each

bootstrap:
	$(MAKE) --directory bootstrap

plan: for-each

detect-drift: for-each

storage: bootstrap
	$(MAKE) --directory storage

provision: bootstrap
	$(MAKE) --directory provisioning

deploy: provision storage
	$(MAKE) --directory deployment

services: bootstrap provision deploy storage
	$(MAKE) --directory services

upgrade: for-each

versions:
	@$(MAKE) --no-print-directory --directory provisioning versions
	@$(MAKE) --no-print-directory --directory deployment versions
