#!/bin/bash
if (( $EUID != 0 )); then
  echo 'Run script as root'
  exit
fi

# Remove user created in base
deluser --remove-home matt

# WSL Default Settings
echo '[boot]' > /etc/wsl.conf
echo 'systemd=true' >> /etc/wsl.conf

# Get the system up to date
apt-get update
apt-get update --fix-missing
apt full-upgrade -y

# Install Ansible To Leverage That For Rest of Setup Work and main community collection for ansible
apt install python3-pip -y && pip install ansible-core

# Pull down from repository and run playbook
mkdir /wsl
cd /wsl
git clone https://github.com/matthew-da-clark/wsl_image_setup.git
cd /wsl/wsl_image_setup
git config --global --add safe.directory '*'
git pull

# Setup Proper Config For Repo
git config --local core.fileMode false

# Install collections that are required for main setup
ansible-galaxy collection install community.general
ansible-galaxy collection install containers.podman
ansible-galaxy collection install community.postgresql

# Main install
ansible-playbook init.yml --inventory inventory -vvv