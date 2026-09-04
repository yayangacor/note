# PC 10

## Install SSH into UbuntuClient
```bash
sudo apt update
sudo apt-get install openssh-server
sudo systemctl status ssh
sudo systemctl enable ssh
```
Follow:
https://askubuntu.com/questions/51925/how-do-i-configure-a-new-ubuntu-installation-to-accept-ssh-connections

## Install Docker in UbuntuClient
```bash
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl status docker
sudo systemctl start docker

sudo docker run hello-world
```
Follow: https://docs.docker.com/engine/install/ubuntu/ > `Install using the apt repository`

## Give prk permissons to Docker
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

## Run Forgejos server in Docker
```bash
docker run --rm data.forgejo.org/forgejo/runner:13 forgejo-runner --version
sudo docker run --rm data.forgejo.org/forgejo/runner:13 \
  forgejo-runner generate-config > data/runner-config.yml
```

```yaml

```
Follow: https://forgejo.org/docs/v15.0/admin/actions/installation/docker/

## Generate SSH key for UbuntuClient
```bash
ssh-keygen -t ed25519 -C "github-actions-ssh"
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

## Forgejo runner
i think no need register? writing in docker compose is enough
```bash
docker compose run --rm runner forgejo-runner register \
  --instance 192.168.1.197:3000	 \
  --token 35e3c7f58eecef232a44f44892d90f66a30c507f \
  --name "docker-compose-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm" \
  --no-interactive
```

runner-config.yml
file: ""
labels: ["ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:full-20.04"]


## CI pipeline
### enable forgejo actions
```bash
nano ./forgejo/gitea/conf/app.ini
```
add:
```yaml
[actions]
ENABLED = true
DEFAULT_ACTIONS_URL = github.com
```

Follow: https://forgejo.org/docs/latest/admin/actions/

## Docker registry
### Create user
```bash
docker run --rm -it --entrypoint sh registry:2 -c "apk add --no-cache apache2-utils > /dev/null && htpasswd -Bnb Group-1 kelargacor" > ./registry_auth/htpasswd
sudo nano /etc/docker/daemon.json
```

```json
{
  "insecure-registries": ["192.168.1.197:5000"]
}
```

### Pull and push redis and postgres images into registry
```bash
sudo docker pull redis:7
sudo docker tag redis:7 192.168.1.197:5000/redis:7
sudo docker push 192.168.1.197:5000/redis:7

sudo docker pull postgres:15
sudo docker tag postgres:15 192.168.1.197:5000/postgres:15
sudo docker push 192.168.1.197:5000/postgres:15

sudo docker images | grep "192.168.1.197:5000"
```
