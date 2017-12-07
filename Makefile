.PHONY: image cluster clean

TERRAFORM ?= terraform

all: image cluster

cluster: .terraform
	$(TERRAFORM) apply

image:
	./image/build

destroy-cluster:
	$(TERRAFORM) destroy

clean: destroy-cluster
	rm -rf data
	rm -rf image/go-ethereum

.terraform:
	$(TERRAFORM) init
