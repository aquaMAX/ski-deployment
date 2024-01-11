#!/usr/bin/env bash
#
# Author : Poong Zui Yong
# Date: January 2024
# Version 1.0.0: Prepare Rocky for Secret Management Deployment
#

# script needs to be run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1

# cd to the directory where the script is located
cd "$(dirname "$0")"

# setup docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# pre-configure docker daemon.json file
mkdir -p /etc/docker
cp -f ./daemon.json /etc/docker/daemon.json
sudo systemctl --now enable docker

# add user to docker group so that user can run docker without root
sudo usermod -aG docker appm

# setup httpd and ssl
sudo dnf -y install httpd mod_ssl
sudo systemctl --now enable httpd
sudo systemctl stop httpd
# setup customize config
cp -f ./secure_proxy.conf /etc/httpd/conf.d/secure_proxy.conf
cp -f ./httpd.conf /etc/httpd/conf/httpd.conf
mv -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
# setup selfsigned certificate
mkdir -p /etc/pki/private
cp -f ./apache-selfsigned.key /etc/ssl/private/apache-selfsigned.key
cp -f ./apache-selfsigned.crt /etc/ssl/certs/apache-selfsigned.crt
chmod 400 /etc/ssl/private/apache-selfsigned.key
chmod 444 /etc/ssl/certs/apache-selfsigned.crt

sudo systemctl restart httpd

echo "Docker related component deployed"
