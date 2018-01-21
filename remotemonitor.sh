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

echo -e $(date -u)'\t'host: chainz.cryptoid.info '\t'connections: "???"'\t'block: $chainz_block "("$chainz_hash")"

## REFERENCE DATA

host=reference.b3nodes.net
ret=$(ssh $user@$host "b3coind getblockcount; b3coind getconnectioncount; height=\$(b3coind getblockcount); b3coind getblockhash \$height; free -m | grep Mem | awk '{print $4}'; free -m | grep Swap | awk '{print $4}'")
blockcount=$(echo $ret | awk '{print $1}')
connectioncount=$(echo $ret | awk '{print $2}')
blockhash=$(echo $ret | awk '{print $3}')
memory=$(echo $ret | awk '{print $7}')
swap=$(echo $ret | awk '{print $14}')
echo -e $(date -u)'\t'host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "("$blockhash")"'\t'Mem: $(printf "%04g" $memory)"MB" Swap: $(printf "%04g" $swap)"MB"


## SEED DATA

user="b3"

for i in $(seq -f "%03g" 1 15); do

	host="seed"$i".b3nodes.net"

	ret=$(ssh $user@$host "b3coind getblockcount; b3coind getconnectioncount; height=\$(b3coind getblockcount); b3coind getblockhash \$height; free -m | grep Mem | awk '{print $4}'; free -m | grep Swap | awk '{print $4}'")
	blockcount=$(echo $ret | awk '{print $1}')
	connectioncount=$(echo $ret | awk '{print $2}')
	blockhash=$(echo $ret | awk '{print $3}')
	memory=$(echo $ret | awk '{print $7}')
	swap=$(echo $ret | awk '{print $14}')
	echo -e $(date -u)'\t'host: $host'\t'connections: $(printf "%03g" $connectioncount)'\t'block: $blockcount "("$blockhash")"'\t'Mem: $(printf "%04g" $memory)"MB" Swap: $(printf "%04g" $swap)"MB"
done


echo "========================="
