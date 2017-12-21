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

echo -e host: chainz.cryptoid.info '\t'connections: "???"'\t'block: $chainz_block "("$chainz_hash")"

## SEED DATA

user="b3"

for i in $(seq -f "%03g" 1 7); do

	host="seed"$i".b3nodes.net"

	ret=$(ssh $user@$host "b3coind getblockcount; b3coind getconnectioncount; height=\$(b3coind getblockcount); b3coind getblockhash \$height; free -m | grep Mem | awk '{print $4}'; free -m | grep Swap | awk '{print $4}'")
	#ssh $user@$host "$blockcount=\$(b3coind getblockcount); $connectioncount=\$(b3coind getconnectioncount); height=\$(b3coind getblockcount); $blockhash=\$(b3coind getblockhash \$height)"
	blockcount=$(echo $ret | awk '{print $1}')
	connectioncount=$(echo $ret | awk '{print $2}')
	blockhash=$(echo $ret | awk '{print $3}')
	memory=$(echo $ret | awk '{print $7}')
	swap=$(echo $ret | awk '{print $14}')
	#blockcount=$(ssh $user@$host b3coind getblockcount)
	#connectioncount=$(ssh $user@$host b3coind getconnectioncount)
	#blockhash=$(ssh $user@$host b3coind getblockhash $blockcount)
	#uptime=$(ssh $user@$host uptime)
	#memory=$(ssh $user@$host free -m | grep Mem | awk '{print $4}')
	#swap=$(ssh $user@$host free -m | grep Swap | awk '{print $4}')
	#echo -e host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "(" $blockhash ")"'\t'Uptime \& load: $uptime -p'\t' Mem: $memory "MB" Swap: $swap "MB"
	echo -e host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "("$blockhash")"'\t'Mem: $(printf "%04g" $memory)"MB" Swap: $(printf "%04g" $swap)"MB"
done
