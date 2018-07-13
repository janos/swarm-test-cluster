.PHONY: image cluster clean

TERRAFORM ?= terraform

all: image jaeger cluster

cluster: .terraform
	$(TERRAFORM) apply -auto-approve

image:
	./image/build

jaeger:
	docker pull jaegertracing/all-in-one:latest

destroy-cluster:
	$(TERRAFORM) destroy -force

clean: destroy-cluster
	rm -rf data
	rm -rf image/go-ethereum

.terraform:
	$(TERRAFORM) init
