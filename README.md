# Go Ethereum Swarm local testing cluster

This repository contains configuration files and scripts
intended for testing local Swarm cluster.


## Dependencies

- Terraform https://www.terraform.io/
- Docker https://www.docker.com/
- rsync
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

## Adding and removing Swarm nodes

Managing a number of nodes can be done using terraform variable *swarm_count*:

    terraform apply -var swarm_count=10

If the number of active containers is less the the one provided in the 
command above, new nodes will be created, otherwise existing will be
terminated to match the desired count.


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


## Accessing the Swarm nodes

As each swarm node's HTTP API is exposed, using the swarm cluster can be
achieved by making a HTTP requests on each node.

For example, uploading a file to the cluster can be done on any node,
let that be the second one exposed on port 8502:

    curl -H "Content-Type: text/plain" --data-binary "some-data" http://localhost:8502/bzz:/

Which will return the hash of the swarm content.

And then requesting the data from the first node:

    curl localhost:8501/bzz:/52c5aa1a731ef529915f6d23287069d34ae7c719a4570137e42fa7d4ae6312ec/

where `52c5aa1a731ef529915f6d23287069d34ae7c719a4570137e42fa7d4ae6312ec`
represents the returned data from the first `curl` request and here acts only
as an example. You should replace it with your own hash.


## Exposing other ports

Terraform file main.tf contains references to the ports that services
listen to within containers. If you need other ports exposed, enable
them in main.tf file and apply with terraform command:

    terraform apply


## Accessing the node's log messages

All logging is handled by Docker and to list log entries use `docker log`
command. For example, to list logs from the third *swarm* container:

    docker log swarm3

To change the log verbosity level:

    terraform apply -var verbosity=6
