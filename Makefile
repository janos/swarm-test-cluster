.PHONY: image cluster clean

TERRAFORM ?= terraform

all: image cluster

cluster: .terraform
	$(TERRAFORM) apply -auto-approve

image:
	./image/build

destroy-cluster:
	$(TERRAFORM) destroy -force

clean: destroy-cluster
	rm -rf data
	rm -rf image/go-ethereum

.terraform:
	$(TERRAFORM) init
