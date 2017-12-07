# Go Ethereum Swarm local testing cluster

This repository contains configuration files and scripts
intended for testing local Swarm cluster.


## Dependencies

- Terraform https://www.terraform.io/
- Docker https://www.docker.com/
- Git https://git-scm.com/
- go-ethereum project under $GOPATH/src/github.com/ethereum/go-ethereum


## First steps

Make sure that you have installed the required dependencies.

Setup everything:

    make

Create a new image:

    make image

Create or update the cluster:

    make cluster

Destroy cluster while preserving the volumes data:

    make destroy-cluster

Destroy cluster and remove data and local copy of go-ethereum repository:

    make clean


## Building Docker image

Docker image requires *go-ethereum* source code under $GOPATH.
General assumption is that the image will be built during the development
of Swarm and that the local changes to go-ethereum source code are
important and will be used.

To build the image execute the following script:

    ./image/build

It will remove the code in *image/go-ethereum* if exists, shallow
clone the repository from local disk and call *docker build* command.

The image that is created will be named *go-ethereum-swarm-test*.


## Creating the cluster

Cluster is managed by Terraform as Docker containers from the same image
within the dedicated Docker network.

Initialize the terraform only once:

    terraform init


After executing:

    terraform apply

the following containers will be created:

  - bootnode
  - geth
  - swarm{1...n}

Each *swarm* container will have its HTTP API port exposed on port number
8500+n, where n is the container serial number from its name.

### Options

File *variables.rf* contains options that can be applied when creating
the cluster. Some of the interesting ones are:

  - verbosity - Verbosity level for swarm, geth and bootnode.
  - swarm_count - Number of swarm containers.
  - docker\_containers\_prefix - Optional prefix for namespacing all
    Docker containers.
  - docker\_network\_name - Docker network name.

### Start more swarm containers

    terraform apply -var swarm_count=10


## State

Bootnode, geth and swarm containers are configured to have their data 
directories mounted to the *data* dir within the terraform configuration
files. For the containers that are named the same, the data will be preserved
on cluster recreation. To clean up the state, just remove appropriate
directories from *data* dir.

Terraform variables docker\_containers\_prefix and docker\_network\_name
can be used to avoid conflicts when creating multiple clusters on the same
host.


## Destroying the cluster

    terraform destroy

