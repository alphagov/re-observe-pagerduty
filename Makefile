.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove all terraform state files
	. ./setup.sh -c

.PHONY: init
init: ## Initialise terraform
	. ./setup.sh -i

.PHONY: plan
plan:  ## Plan terraform
	. ./setup.sh -p

.PHONY: apply
apply: ## Apply terraform
	. ./setup.sh -a
