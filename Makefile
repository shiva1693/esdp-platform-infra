ENV ?= dev
TF_ROOT := environments/$(ENV)

.PHONY fmt init validate plan apply destroy

fmt:
	terraform fmt -recursive

init:
	cd $(TF_ROOT) && terraform init -backend-config=backend.hcl

validate:
	cd $(TF_ROOT) && terraform validate

plan:
	cd $(TF_ROOT) && terraform plan -var-file=terraform.tfvars

apply:
	cd $(TF_ROOT) && terraform plan -var-file=terraform.tfvars

destroy:
	cd $(TF_ROOT) && terraform destroy -var-file=terraform.tfvars