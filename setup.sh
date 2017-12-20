#!/bin/bash


## create swap file
grep -q "swapfile" /etc/fstab

if [ $? -ne 0 ]; then
        fallocate -l 1G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        sysctl vm.swappiness=10
        echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
        free -h
        sleep 5
fi


## update system
apt-get update && apt-get -y upgrade


## add sudo user to system
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
#	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists"
	else
#		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
#		useradd -m -p $pass $username
		adduser $username
#		[ $? -eq 0 ] && echo $username " has been added to system!" || echo "Failed to add user!"
#		usermod -a -G sudo $username
#		echo $username " added to sudo group!"
		adduser $username sudo
	fi
else
	echo "Only root may add a user to the system!"
	exit 2
fi

## disable ssh password based login
#grep -q "ChallengeResponseAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*ChallengeResponseAuthentication[[:space:]]yes.*/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config || echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
#grep -q "^[^#]*PasswordAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

## open firewall
ufw allow 5647

## install git, clone wallet repo and tools
git clone https://github.com/B3-Coin/B3-CoinV2.git /home/$username/B3-CoinV2
git clone https://github.com/despotak/b3-tools.git /home/$username/b3-tools

## install dependencies
apt-get -y update && sudo apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev

## enter src dir, make, compile, and symlink bin into /usr/bin/
cd /home/$username/B3-CoinV2/src/leveldb
#chmod +x build_detect_platform
make clean
make libmemenv.a libleveldb.a
cd ..
make -f makefile.unix
ln -s /home/$username/B3-CoinV2/src/b3coind /usr/bin/b3coind

## initialize the daemon
#b3coind --datadir=/home/$username/.B3-CoinV2/
#wait 5
#b3coind stop

mkdir /home/$username/.B3-CoinV2/
touch /home/$username/.B3-CoinV2/b3coin.conf

## create b3coin.conf
echo "rpcuser=b3coinrpc" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo "rpcpassword="$pass | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "daemon=1" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "server=1" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "listen=1" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "staking=0" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "promode=1" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "logtimestamps=1" | tee -a /home/$username/.B3-CoinV2/b3coin.conf
echo "maxconnections=300" | tee -a /home/$username/.B3-CoinV2/b3coin.conf

## reboot
reboot now

## login as user
#login $username

## start daemon
#b3coind
