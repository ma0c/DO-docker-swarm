#!/bin/bash
echo "Creating the swarm manager with name $MANAGER_NAME"
docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-private-networking=true --digitalocean-region $DIGITALOCEAN_REGION --digitalocean-size $DIGITALOCEAN_MANAGER_SIZE  $MANAGER_NAME
for ((i=1; i<=$NUM_WORKERS; i++))
do
echo "Creating node $i with name ${SWARM_WORKERS_PREFIX}${i}"
docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-private-networking=true --digitalocean-region $DIGITALOCEAN_REGION --digitalocean-size $DIGITALOCEAN_WORKER_SIZE  ${SWARM_WORKERS_PREFIX}${i}
done
