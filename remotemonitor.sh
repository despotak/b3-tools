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

## SEED DATA

user="b3"

for i in $(seq -f "%03g" 1 2); do

	host="seed"$i".b3nodes.net"
	blockcount=$(ssh $user@$host b3coind getblockcount)
	connectioncount=$(ssh $user@$host b3coind getconnectioncount)
	blockhash=$(ssh $user@$host b3coind getblockhash $blockcount)
	uptime=$(ssh $user@$host uptime)
	memory=$(ssh $user@$host free -m | grep Mem | awk '{print $4}')
	swap=$(ssh $user@$host free -m | grep Swap | awk '{print $4}')
	echo -e host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "(" $blockhash ")"'\t'Uptime \& load: $uptime'\t' Mem: $memory "MB" Swap: $swap "MB"

done
