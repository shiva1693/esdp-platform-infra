ENV ?= dev
TF_ROOT := environments/$(ENV)

.PHONY: help fmt init validate plan apply destroy

help:
	@echo "Usage:"
	@echo "  make fmt"
	@echo "  make init ENV=dev"
	@echo "  make validate ENV=dev"
	@echo "  make plan ENV=dev"
	@echo "  make apply ENV=dev"
	@echo "  make destroy ENV=dev"

fmt:
	terraform fmt -recursive

init:
	cd $(TF_ROOT) && terraform init -backend-config=backend.hcl

validate:
	cd $(TF_ROOT) && terraform validate

plan:
	cd $(TF_ROOT) && terraform plan -var-file=terraform.tfvars

apply:
	cd $(TF_ROOT) && terraform apply -var-file=terraform.tfvars

destroy:
	cd $(TF_ROOT) && terraform destroy -var-file=terraform.tfvars