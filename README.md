# b3-tools

## monitor.sh
#### Usage:
 * `./monitor.sh`
 * `watch -n <interval> -d ./monitor.sh` (for auto refresh every \<interval\> seconds)

#### Requirements:
 * jq (json parser) https://stedolan.github.io/jq/download/

Prints information about your B3 Fundamental Node

### Screenshots
![monitor.sh](https://i.imgur.com/0n2gE9p.png)

## fnscrapper.sh
#### Usage:
 * `./fnscrapper.sh <starting_block> <ending_block>` (if you just want to see the results in the console
 * `./fnscrapper.sh <starting_block> <ending_block> > file.csv` (if you want the results in a .cvs file)

Prints Fundamental Node winners for each block, along with the respective reward
