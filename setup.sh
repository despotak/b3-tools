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
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists"
	else
		adduser $username
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
apt-get -y update && apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev


## enter src dir, make, compile, and symlink bin into /usr/bin/
cd /home/$username/B3-CoinV2/src/leveldb
make clean
make libmemenv.a libleveldb.a
cd ..
make -f makefile.unix
ln -s /home/$username/B3-CoinV2/src/b3coind /usr/bin/b3coind


## create b3coin.conf
mkdir /home/$username/.B3-CoinV2/
touch /home/$username/.B3-CoinV2/b3coin.conf

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


## change ownership
chown -R $username:$username /home/$username/B3-CoinV2/
chown -R $username:$username /home/$username/.B3-CoinV2/
chown -R $username:$username /home/$username/b3-tools/


## edit .bashrc to show hostname instead of shortname
sed -i 's/u@\\h/u@\\H/g' /home/$username/.bashrc


## import ssh key (do you have a  better idea?)
mkdir /home/$username/.ssh
touch /home/$username/.ssh/authorized_keys
#cdr Archangel
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDPqKkZvhLU2y/+uUb5X4FUNTb0ojce69pPjhL9xX/Zh++2FvT6koVyjUr8B5j51oacbWAamEK9p9ozntoX+C2SR+JcPIoTmlUs9cFYmCefBH06clGGc9KBwIsURRy9TgrQcYt9JKxgy3KdVx0S8r+DCU8lu+q4scIKlzx+MbIAxsuLOqhfrkYwPKLs4yjpboNXOHo5l+sp6P1FJpK51i828phygGemvzSTR3cm3QPb7TYtXAnkDZQDGr0PDra8FiNq+Q1qyFLguFUJafrwX4zGahb9Tn3WRobFVVRpqL2+SydDjvIFk8jC1uQAQz+PuCvEN/1TZCqvYEV/hbR/Gvj despotak@CHAOS" | tee -a /home/$username/.ssh/authorized_keys
#SkyHyperV
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH4JYQo6bC1R8zTHKnBiB7Md7eCvDP8A167hy2ksnmlrk6vWkP1qmr5shN/AMjYw2PR9U+UubHRtMiRsVvE1AScw/MJDH8KEbrK5TdTDMG0QK7UHBtktdBotp3u14CBrlGAVSdTxe+ZD8ZAS3vCH6/Ppj91DwkBqoig31uabeK5frOH5B+5qSAF1SsHC23HgpkX6HgsvZD26IF/AVzefGmNKTF6Pwlooe7/wsDYm9i576vrpWyHcW8Au5K/XV+13XhBGBddbhi+fHEWjtllH0FbPWvSlDz13yCl85aYAMzQNkJA1HXqN7HEnOfBlKTLNUOYVHQ8KaWgwVg5ppQmd+p kasun@Naushads-MacBook-Pro.local" | tee -a /home/$username/.ssh/authorized_keys


## add b3coind on /etc/rc.local
chmod +x /et/rc.local
echo b3coind | tee -a /etc/rc.local


## reboot
reboot now
