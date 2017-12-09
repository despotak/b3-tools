#!/bin/bash
## Usage: ./fnscrapper.sh <starting_block> <ending_block> (if you just want to see the results in the console
##	  ./fnscrapper.sh <starting_block> <ending_block> > file.csv (if you want the results in a .cvs file)
##
## Prints Fundamental Node winners for each block, along with the respective reward
##
## Author(s):
##	cdr Archangel
##
## version: 0.0.1
##

for i in `seq $1 $2`;
do
	TXID=$(~/b3/github/B3-CoinV2/src/b3coind getblockbynumber $i | jq .tx[1])
	TXID="${TXID%\"}"
	TXID="${TXID#\"}"
	ADD=$(~/b3/github/B3-CoinV2/src/b3coind gettransaction $TXID | jq .vout[3].scriptPubKey.addresses[0])
	ADD="${ADD%\"}"
        ADD="${ADD#\"}"
	REW=$(~/b3/github/B3-CoinV2/src/b3coind gettransaction $TXID | jq .vout[3].value)
	echo $i,$ADD,$REW
done
