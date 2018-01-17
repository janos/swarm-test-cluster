# Go Ethereum Swarm local metrics setup

This repository contains configuration files and scripts intended for testing metrics and stats.


## Dependencies

- Terraform https://www.terraform.io/
- Docker https://www.docker.com/


## First steps

Setup everything:

    make

Destroy cluster and remove data:

    make clean


### Options

File *variables.rf* contains options that will be applied when creating the metrics setup:

  - docker\_containers\_prefix - Optional prefix for namespacing all
    Docker containers.
  - docker\_network\_name - Docker network name.


## State

State is kept on the Docker containers for now.
