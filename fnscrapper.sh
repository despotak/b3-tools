#!/bin/bash

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
