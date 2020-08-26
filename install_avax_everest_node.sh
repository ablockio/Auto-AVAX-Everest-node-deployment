#!/bin/bash

#######################################
# Bash script to install dependencies in UBUNTU
# for https://www.avalabs.org/ Nodes
# ######################################

_VERSION=0.6.4

echo '    /\ \    / /\    \ \ / / |  ____\ \    / /  ____|  __ \|  ____|/ ____|__   __|'
echo '   /  \ \  / /  \    \ V /  | |__   \ \  / /| |__  | |__) | |__  | (___    | |   '
echo '  / /\ \ \/ / /\ \    > <   |  __|   \ \/ / |  __| |  _  /|  __|  \___ \   | |   '
echo ' / ____ \  / ____ \  / . \  | |____   \  /  | |____| | \ \| |____ ____) |  | |   '
echo '/_/    \_\/_/    \_\/_/ \_\ |______|   \/   |______|_|  \_\'$_VERSION'_|_____/   |_|   '
echo 'If you want to help us, contact us on contact@ablock.io'


echo '### Checking if systemd is supported...'
if systemctl show-environment &> /dev/null ; then
SYSTEMD_SUPPORTED=1
echo 'systemd is available, using it'
else
echo 'systemd is not available on this machine, will use supervisord instead'
fi

echo '### Updating packages...'
sudo apt-get update -y

echo '### Installing nodejs...'
sudo apt-get -y install nodejs
sudo apt-get -y install npm

echo '### Cloning gecko directory...'
cd $HOME
wget https://github.com/ava-labs/gecko/releases/download/v$_VERSION/avalanche-linux-$_VERSION.tar
tar -xvf avalanche-linux-$_VERSION.tar

cd avalanche-$_VERSION

echo '### Creating AVA node service...'
if [ -n "$SYSTEMD_SUPPORTED" ]; then
sudo USER=$USER bash -c 'cat <<EOF > /etc/systemd/system/avaxnode.service
[Unit]
Description=AVAX Everest Node service
After=network.target

[Service]
User=$USER
Group=$USER

WorkingDirectory=$HOME/avalanche-'$_VERSION'
ExecStart=$HOME/avalanche-'$_VERSION'/avalanche

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF'
else
sudo bash -c 'cat <<EOF > /etc/supervisor/conf.d/avaxnode.conf
[program:avaxnode]
directory=/home/$SUDO_USER/avalanche-'$_VERSION'
command=/home/$SUDO_USER/avalanche-'$_VERSION'/avalanche
user=$SUDO_USER
environment=HOME="/home/$SUDO_USER",USER="$SUDO_USER"
autostart=true
autorestart=true
startsecs=10
startretries=20
stdout_logfile=/var/log/avaxnode-stdout.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=1
stderr_logfile=/var/log/avaxnode-stderr.log
stderr_logfile_maxbytes=10MB
stderr_logfile_backups=1
EOF'
fi

echo '### Launching AVAX node...'
if [ -n "$SYSTEMD_SUPPORTED" ]; then
sudo systemctl enable avaxnode
sudo systemctl start avaxnode
echo 'Type the following command to monitor the AVA node service:'
echo '    sudo systemctl status avaxnode'
else
sudo service supervisor start
sudo supervisorctl start avaxnode
echo 'Type the following command to monitor the AVA node service:'
echo '    sudo supervisorctl status avaxnode'
fi

echo '### Cloning Script directory...'
cd $HOME
sudo rm -R Auto-AVAX-Everest-node-deployment/
git clone https://github.com/ablockio/Auto-AVAX-Everest-node-deployment.git
cd Auto-AVAX-Everest-node-deployment
npm i
