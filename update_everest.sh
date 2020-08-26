#!/bin/bash

#######################################
# Bash script to install dependencies in UBUNTU
# for https://www.avalabs.org/ Nodes
#######################################
echo '   _________   _________              ________  ___________ _______      _____  .____    .___ '
echo '  /  _  \   \ /   /  _  \             \______ \ \_   _____/ \      \    /  _  \ |    |   |   |'
echo ' /  /_\  \   Y   /  /_\  \    ______   |    |  \ |    __)_  /   |   \  /  /_\  \|    |   |   |'
echo '/    |    \     /    |    \  /_____/   |    `   \|        \/    |    \/    |    \    |___|   |'
echo '\____|__  /\___/\____|__  /           /_______  /_______  /\____|__  /\____|__  /_______ \___|'
echo '        \/              \/ script powered by  \/ ablock \/         \/         \/        \/   '
echo 'If you want to help us, contact us on contact@ablock.io'

AVA_VERSION=$1
_VERSION=$1
echo '### Starting update of AVAX Node to '$AVA_VERSION'...'

echo '### Stopping existing AVA node if launched manually ...'
if [  -f "/etc/systemd/system/avaxnode.service" ]; then
SYSTEMD_INSTALLED=1
echo '### systemd is used'
sudo systemctl stop avaxnode
elif [  -f "/etc/supervisor/conf.d/avaxnode.conf" ]; then
echo '### supervisor is used'
sudo supervisorctl stop avaxnode
else
echo '### nohup is used'
NOHUP_USED=1
PID=`ps -ef | grep build/ava | grep root | tr -s ' ' | cut -d ' ' -f2`
echo $PID
sudo kill -9 $PID
fi


echo '### Checking if systemd is supported...'
if systemctl show-environment &> /dev/null ; then
SYSTEMD_SUPPORTED=1
echo 'systemd is available, using it'
else
echo 'systemd is not available on this machine, will use supervisord instead'
fi

if [ -n "$NOHUP_USED" ]; then
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
fi


echo '### Downloading latest version...'

cd $HOME
wget https://github.com/ava-labs/gecko/releases/download/v$_VERSION/avalanche-linux-$_VERSION.tar
tar -xvf avalanche-linux-$_VERSION.tar.gz

cd avalanche-$_VERSION


echo '### Launching AVA node...'
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
