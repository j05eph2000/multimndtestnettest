#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]  
then
 
apt-get update -y
#DEBIAN_FRONTEND=noninteractive apt-get update 
#DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade
apt install -y software-properties-common 
apt-add-repository -y ppa:bitcoin/bitcoin 
apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw python virtualenv pv pkg-config libevent-dev  libdb5.3++ unzip 



fallocate -l 8G /dswapfile
chmod 600 /dswapfile
mkswap /dswapfile
swapon /dswapfile
swapon -s
echo "/dswapfile none swap sw 0 0" >> /etc/fstab

fi
  #wget https://github.com/wagerr/wagerr/releases/download/v3.0.1/wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  
  #wget https://github.com/wagerr/Wagerr-Blockchain-Snapshots/releases/download/Block-826819/826819.zip -O bootstrap.zip
  export fileid=1P5lUTnLHHCYSh-vV46Fs6RM5IRz6S3PS
  export filename=dashcore-0.14.0.5-x86_64-linux-gnu.tar.gz
  wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)

  #export fileid=1GiSVHogUMeePxPbjuyDwg6jgYLrN7jbm
  #export filename=bootstrap.zip
  #wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
  #   | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt
  #
  #wget --load-cookies cookies.txt -O $filename \
  #   'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  
  wget https://dash-bootstrap.ams3.digitaloceanspaces.com/testnet/2019-12-11/bootstrap.dat.zip -O dbootstrap.zip   
  tar xvzf dashcore-0.14.0.5-x86_64-linux-gnu.tar.gz
  
  
  chmod +x dashcore-0.14.0/bin/*
  sudo mv  dashcore-0.14.0/bin/* /usr/local/bin
  rm -rf dashcore-0.14.0.5-x86_64-linux-gnu.tar.gz

  sudo apt install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc

  touch masternode.conf

 ## Setup conf
 IP=$(curl -s4 api.ipify.org)
 mkdir -p ~/bin
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"

echo ""
echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT


for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  

  echo ""
  echo "Enter port for node $ALIAS"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  RPCPORT=$(($PORT*10))
  echo "The RPC port is $RPCPORT"

  ALIAS=${ALIAS}
  CONF_DIR=~/.dash_$ALIAS
  
  # Create scripts
  echo '#!/bin/bash' > ~/bin/dashd_$ALIAS.sh
  echo "dashd -daemon -conf=$CONF_DIR/dash.conf -datadir=$CONF_DIR "'$*' >> ~/bin/dashd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/dash-cli_$ALIAS.sh
  echo "dash-cli -conf=$CONF_DIR/dash.conf -datadir=$CONF_DIR "'$*' >> ~/bin/dash-cli_$ALIAS.sh
  chmod 755 ~/bin/dash*.sh

  mkdir -p $CONF_DIR
  unzip  dbootstrap.zip -d $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> dash.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> dash.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> dash.conf_TEMP
  echo "rpcport=$RPCPORT" >> dash.conf_TEMP
  echo "testnet=1" >> dash.conf_TEMP
  echo "listen=1" >> dash.conf_TEMP
  echo "server=1" >> dash.conf_TEMP
  echo "daemon=1" >> dash.conf_TEMP
  echo "logtimestamps=1" >> dash.conf_TEMP
  echo "maxconnections=256" >> dash.conf_TEMP
  echo "masternode=1" >> dash.conf_TEMP
  echo "" >> dash.conf_TEMP
 
  echo "" >> dash.conf_TEMP
  echo "port=$PORT" >> dash.conf_TEMP
  
  echo "masternodeblsprivkey=$PRIVKEY" >> dash.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv dash.conf_TEMP $CONF_DIR/dash.conf
  
  #sh ~/bin/wagerrd_$ALIAS.sh
  
  cat << EOF > /etc/systemd/system/dash_$ALIAS.service
[Unit]
Description=dash_$ALIAS service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/dashd -daemon -conf=$CONF_DIR/dash.conf -datadir=$CONF_DIR
ExecStop=/usr/local/bin/dash-cli -conf=$CONF_DIR/dash.conf -datadir=$CONF_DIR stop
Restart=always
PrivateTmp=true
TimeoutStartSec=10m
StartLimitInterval=0
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 10
  systemctl start dash_$ALIAS.service
  systemctl enable dash_$ALIAS.service >/dev/null 2>&1
  
#cd $CONF_DIR
#git clone https://github.com/dashpay/sentinel.git
#cd sentinel
#virtualenv venv
#venv/bin/pip install -r requirements.txt
#venv/bin/python bin/sentinel.py
#cd

 #(crontab -l 2>/dev/null; echo "* * * * * cd $CONF_DIR/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log") | crontab -
 #(crontab -l 2>/dev/null; echo "* * * * * pidof dashd || $CONF_DIR/dashd") | crontab -
#	   sudo service cron reload
echo -e "$ALIAS $IP:$PORT $PRIVKEY " >> masternode.conf
done
