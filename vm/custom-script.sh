#!/bin/bash
set -e

# sudo DEBIAN_FRONTEND="noninteractive" 
sudo echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# sudo apt update -y

echo "add docker key"

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
apt-cache policy docker-ce
sudo apt install docker-ce -y

echo "Install Java JDK"
sudo apt install default-jdk-headless -y 

echo "Install Docker engine"
sudo systemctl enable docker

echo "Install Jenkins"
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install jenkins -y
sudo service jenkins restart

#sudo apt install git