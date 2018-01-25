#!/bin/bash
echo "Creating the Docker registry with name $REGISTRY_NAME"
docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-private-networking=true --digitalocean-region $DIGITALOCEAN_REGION --digitalocean-size $DIGITALOCEAN_REGISTRY_SIZE  $REGISTRY_NAME
