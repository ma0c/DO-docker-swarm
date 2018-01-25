# Provisionate a aws cluster

> Based on [this repo](https://github.com/contraslash/aws-docker-swarm)

First you are going to need a [DO Access Token](https://cloud.digitalocean.com/settings/api/tokens/new), Be careful and store in a safe place.

Before go on, take a look to DO regions and size codes

```
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_OAUTH_TOKEN}" "https://api.digitalocean.com/v2/regions"

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_OAUTH_TOKEN}" "https://api.digitalocean.com/v2/sizes"
```

Also, take a look to [DO's Docker Machine Driver](https://docs.docker.com/machine/drivers/digital-ocean/)

First edit the envvars.sh with the proper configuration.


Then load the env vars
```
source envvars.sh
```

Then execute the creating script

```
bash create.sh
```

After this, you should have a cluster provioned with docker.

To create a swarm first you need to get the internal IP of the manager node.

```
docker-machine ssh $MANAGER_NAME ifconfig eth0
```

With that IP in mind create a swarm in the manager node

```
eval $(docker-machine env $MANAGER_NAME)
docker swarm init --advertise-addr <REPLACE WITH THE IP>
```

Put `Manager IP` and `Docker Token` in envvars.sh and reload

```
source envvars.sh
```

And finally join every node to the swarm.

To do this, modify join_swarm.sh with the command from `swarm init`

```
bash join_swarm.sh
```

### Create a registry

First we need to create a machine provisioned with docker, to do this we can execute `create_registry.sh`

```
bash create_registry.sh
```

Then log in the registry machine and execute the next tasks

```
# First we're going to need a SSL cert, and we recommend to use certbot
sudo add-apt-repository ppa:certbot/certbot

sudo apt-get update

sudo apt-get install certbot

letsencrypt certonly --keep-until-expiring --standalone -d registry.example.combine --email info@finantic.co

# Enter to the letsencrypt's certs directory
cd /etc/letsencrypt/live/regstry.example.com/

# Then we need to combine cert.pem and chain.pem to create a domain.crt
cat cert.pem chain.pem > domain.crt
# And for legibility purposes rename privkey.pem to domain.key
cp privkey.pem domain.key
```

> This is taked from [here](https://gist.github.com/PieterScheffers/63e4c2fd5553af8a35101b5e868a811e)

The last step is to create users to login to the registry

```
htpasswd -Bbn user password >> /data/registry/auth/htpasswd
```

With the certs ready, we just execute the new registry container

```
docker run -d -p 5000:5000 \
  --restart=always \
  --name registry   \
  -v /data/registry/auth:/auth \
  -e REGISTRY_AUTH="htpasswd"   \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm"   \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd   \
  -v /etc/letsencrypt/live/registry.finantic.co:/certs   \
  -v /data/registry/registry:/var/lib/registry   \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt   \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key   \
  registry:2
```
