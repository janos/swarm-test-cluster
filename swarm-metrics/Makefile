.PHONY: cluster clean

TERRAFORM ?= terraform

all: cluster

cluster: .terraform
	$(TERRAFORM) init
	$(TERRAFORM) apply -auto-approve

destroy-cluster:
	$(TERRAFORM) destroy -force

clean: destroy-cluster
	rm -rf data

.terraform:
	$(TERRAFORM) init
