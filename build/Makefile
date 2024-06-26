# Get only the list of files that will be used to generate the Workbook
TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: all
all: init build-workbook build-workbook-public build-workbook-export build-bicep ## Execute all steps

.PHONY: init
init: ## Initialize terraform
	terraform fmt -check
	terraform init
	terraform validate -no-color

.PHONY: build-workbook
build-workbook: ## Execute terraform plan
	mkdir -p artifacts
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))
	terraform apply -no-color tfplan
# Exept ReliabilityWorkbookPublic.workbook from the list of files. It will be used for developer mode only.
	(cd artifacts && ls *.workbook | grep -v ReliabilityWorkbookPublic.workbook > workbook_filelist)

.PHONY: build-workbook-public
build-workbook-public: ## Execute terraform plan to generate public edition
	terraform plan -input=false -no-color -out tfplan -target local_file.workbook_public
	terraform apply -no-color tfplan

.PHONY: build-workbook-export
build-workbook-export: ## Execute terraform plan to generate public edition
	terraform plan -input=false -no-color -out tfplan -target local_file.workbook_export
	terraform apply -no-color tfplan

.PHONY: build-bicep
build-bicep: ## Build Bicep files
	mkdir -p artifacts
	az bicep build -f main.bicep --stdout > azuredeploy.json
	mv azuredeploy.json artifacts

.PHONY: clean
clean: ## Remove generated files
	rm -f tfplan
	rm -rf ./artifacts/
