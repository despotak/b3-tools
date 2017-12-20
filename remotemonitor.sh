#!/bin/bash


##FUNCTIONS##

#Trims leading and trailing quotation marks
function trim () {
	r=$1
	r="${r%\"}"
	r="${r#\"}"
	echo $r
}



## EXPLORER DATA

chainz_block=$(curl -s https://chainz.cryptoid.info/b3/api.dws?q=getblockcount)
url="https://chainz.cryptoid.info/b3/api.dws?q=getblockhash;height="$chainz_block
chainz_hash=$(trim $(curl -s $url))

echo -e host: chainz.cryptoid.info '\t'connections: "???"'\t'block: $chainz_block "(" $chainz_hash ")"


for i in $(seq -f "%03g" 1 2); do

	host="seed"$i".b3nodes.net"
	blockcount=$(ssh "b3@"$host b3coind getblockcount)
	connectioncount=$(ssh "b3@"$host b3coind getconnectioncount)
	blockhash=$(ssh "b3@"$host b3coind getblockhash $blockcount)
	uptime=$(ssh "b3@"$host uptime)
	memory=$(ssh "b3@"$host free -m | grep Mem | awk '{print $4}')
	swap=$(ssh "b3@"$host free -m | grep Swap | awk '{print $4}')
	echo -e host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "(" $blockhash ")"'\t'Uptime \& load: $uptime'\t' Mem: $memory "MB" Swap: $swap "MB"

done


#chainz_block=$(curl -s https://chainz.cryptoid.info/b3/api.dws?q=getblockcount)
#url="https://chainz.cryptoid.info/b3/api.dws?q=getblockhash;height="$chainz_block
#chainz_hash=$(trim $(curl -s $url))

#echo -e host: chainz.cryptoid.info '\t'connections: "???"'\t'block: $chainz_block "(" $chainz_hash ")"

#host=$seed0001
#blockcount=$(ssh $seed0001 /home/fn/b3coind getblockcount)
#connectioncount=$(ssh $seed0001 /home/fn/b3coind getconnectioncount)
#blockhash=$(ssh $seed0001 /home/fn/b3coind getblockhash $blockcount)
#echo -e host: $host'\t'connections: $connectioncount'\t'block: $blockcount "(" $blockhash ")"


#host=$seed0002
#blockcount=$(ssh $seed0002 /home/fn/b3coind getblockcount)
#connectioncount=$(ssh $seed0002 /home/fn/b3coind getconnectioncount)
#blockhash=$(ssh $seed0002 /home/fn/b3coind getblockhash $blockcount)
#echo -e host: $host'\t'connections: $connectioncount'\t'block: $blockcount "(" $blockhash ")"
