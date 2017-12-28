#!/bin/bash

## get username
username=$(whoami)


## pull wallet repo and tools
# B3-CoinV2 wallet
cd /home/$username/B3-CoinV2
git fetch							# Download objects and refs from remote repository.
git checkout -B latest_stable --track origin/latest_stable	# Updates files in the working tree to match the version in the index or the specified tree.

#b3-tools
cd /home/$username/b3-tools
git pull


## install dependencies
#sudo apt-get -y update && apt-get -y upgrade


## stop daemon
/home/$username/B3-CoinV2/src/b3coind stop
sleep 2


## enter src dir, make, compile, and symlink bin into /usr/bin/
#cd /home/$username/B3-CoinV2/src/leveldb
#make clean
#make libmemenv.a libleveldb.a
#cd ..
cd /home/$username/B3-CoinV2/src
make -f makefile.unix
sudo ln -s /home/$username/B3-CoinV2/src/b3coind /usr/bin/b3coind


## start daemon
/usr/bin/b3coind
