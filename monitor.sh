#!/bin/bash
## Usage: monitor.sh
##	  watch -n <interval> -d ./monitor.sh (for auto refresh every <interval> seconds)
##
## Requirements:
##	jq (json parser) https://stedolan.github.io/jq/download/
##
## Prints information about your B3 Fundamental Node
##
## Author(s):
##	cdr Archangel
##
## version: 1.0.0
##

##SETUP##

#Check that jq json parser is installed
command -v jq >/dev/null 2>&1 || { echo >&2 "ERROR: monitor.sh requires \"jq\" but it's not installed.

Please use your package manager to install \"jq\".

Debian:		sudo apt-get install jq
Fedora:		sudo dnf install jq
openSUSE:	sudo zypper install jq
Arch:		sudo pacman -Sy jq

Aborting."; exit ; }


#Please set your path to the b3coind binary here
B3_PATH=~/B3-CoinV2/src

##FUNCTIONS##

#Trims leading and trailing quotation marks
function trim () {
	r=$1
	r="${r%\"}"
	r="${r#\"}"
	echo $r
}

##INIT ENV##
last_date=
last_txid=
last_amount=
last_block_hash=
last_block=


##MAIN LOGIC##

#Machine info
host=$(hostname)
ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

#Node info
secs=$($B3_PATH/b3coind fundamentalnodelist activeseconds $ip | awk '{print $3}')
up=$(eval "echo $(date -ud "@$secs" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")
version=$(trim $($B3_PATH/b3coind getinfo | jq .version))
protocol=$($B3_PATH/b3coind fundamentalnodelist full $ip | awk '{print $6}')
local_block=$($B3_PATH/b3coind getblockcount)
local_hash=$($B3_PATH/b3coind getblockhash $local_block)
chainz_block=$(curl -s https://chainz.cryptoid.info/b3/api.dws?q=getblockcount)
url="https://chainz.cryptoid.info/b3/api.dws?q=getblockhash;height="$chainz_block
chainz_hash=$(trim $(curl -s $url))

#FMN info
status=$($B3_PATH/b3coind fundamentalnodelist full $ip | awk '{print $5}')
address=$($B3_PATH/b3coind fundamentalnodelist full $ip | awk '{print $7}')
rank=$($B3_PATH/b3coind fundamentalnodelist rank $ip | awk '{print $3}')

#Last payment info
json=$($B3_PATH/b3coind listtransactions \* 10)
for i in `seq 0 9`;
do
	if [ $(echo $json | jq .[$i].category) = "\"generate\"" ]; then
		if [ $(trim $(echo $json | jq .[$i].address)) = $address ]; then
			last_date=$(echo $json | jq .[$i].timereceived)
			last_txid=$(trim $(echo $json | jq .[$i].txid))
			last_amount=$($B3_PATH/b3coind gettransaction $last_txid | jq .vout[3].value)
			last_block_hash=$(trim $($B3_PATH/b3coind gettransaction $last_txid | jq .blockhash))
			last_block=$($B3_PATH/b3coind getblock $last_block_hash | jq .height)
		fi
	fi
done 

#Future expectations
total_fns=$($B3_PATH/b3coind fundamentalnode count)
expactation=$(($last_block+$total_fns-$chainz_block))
time_expactation=$(awk "BEGIN {print $expactation/240*86400; exit}")

#Current balance
balance=$($B3_PATH/b3coind getbalance)

##OUTPUT##

echo "=================================="
echo "hostname		: " $host
echo "host uptime/load	: " $(uptime)
echo "node uptime		: " $up
echo "node ip			: " $ip
echo "node version		: " $version
echo "node protocol		: " $protocol
echo "hash of the"
echo "block (local)		: " $local_block "(" $local_hash ")"
echo "block (chainz)		: " $chainz_block "(" $chainz_hash ")"
echo "FMN status		: " $status
echo "FMN address		: " $address
echo "FMN rank		: " $rank
echo "FMN last payment	: " $(date -d @$last_date)
echo "FMN last reward		: " $(printf "%'.6f" $last_amount) "B3"
echo "FMN last reward block	: " $last_block
echo "FMN next expected reward: " "in" $expactation "more blocks or" $(eval "echo $(date -ud "@$time_expactation" +'$((%s/3600/24)) days %H hours')") "(highly experimental)"
echo "FMN balance		: " $(printf "%'.6f" $balance) "B3"
echo "=================================="
