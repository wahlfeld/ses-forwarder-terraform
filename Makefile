SHELL := /bin/bash
ROOT=${PWD}

.PHONY: all

default: validate

validate:
	$(ROOT)/checks/validate.sh

docs:
	terraform-docs markdown ${ROOT}/example --output-file ../README.md --hide modules --hide providers --hide outputs --hide resources
