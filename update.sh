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


## stop daemon
ps cax | grep b3coind > /dev/null
if [ $? -eq 0 ]; then
	#echo "Process is running."
	/home/$username/B3-CoinV2/src/b3coind stop
else
	echo "b3coind is not running."
fi

sleep 2


## enter src dir, make, compile, and symlink bin into /usr/bin/
#cd /home/$username/B3-CoinV2/src/leveldb
#make clean
#make libmemenv.a libleveldb.a
#cd ..
cd /home/$username/B3-CoinV2/src
make -f makefile.unix
if [ -h "/usr/bin/b3coind" ]; then
	echo Symbolic link already exists
else
	sudo ln -s /home/$username/B3-CoinV2/src/b3coind /usr/bin/b3coind
	echo Symbolic link added
fi


## start daemon
/usr/bin/b3coind
