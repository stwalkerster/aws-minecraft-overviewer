#!/bin/bash -e
sudo apt-get update -y
sleep 10
sudo apt-get install -q -y docker.io git

sudo mkdir /opt/build
sudo mv /tmp/Dockerfile /opt/build/Dockerfile
sudo git clone https://github.com/overviewer/Minecraft-Overviewer.git /opt/build/git
cd /opt/build
sudo docker build -t docker.scimonshouse.net/overviewer:latest -t docker.scimonshouse.net/overviewer:${mc_version} --build-arg MinecraftVersion=${mc_version} .
sudo docker rmi ubuntu:focal
sudo docker system prune -f
cd /opt
sudo rm -rf /opt/build

# sudo apt-get install -q -y nginx
# sudo chmod -R a+rwX /var/www/html
# sudo find /var/www/html/ -mindepth 1 -delete

sudo apt-get install -q -y rsync

# sudo git clone https://github.com/overviewer/Minecraft-Overviewer-Addons.git
# sudo mkdir -p data/output
# sudo chmod -R a+rwX data/
# sudo mv Minecraft-Overviewer-Addons/exmaple data/exmaple
# sudo rm -rf Minecraft-Overviewer-Addons
