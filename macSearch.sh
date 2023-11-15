#!/bin/bash
# purpose  : Restun vendor name based on a given hardware mac address
# requires : curl, jq

if [ $# -eq 0 ]; then
    echo ""
    echo " `basename $0` <mac address>"
    echo ""
    exit 1
fi

search=$(echo $1 | sed "s/://g")
search=$(echo $search | sed "s/\.//g")
search=$(echo $search | sed "s/-//g")

url='https://api.macvendors.com/'$search

result=$(curl --no-progress-meter $url)

vendor=$(echo $result | jq '. [] | .detail')

echo ""
echo "Vendor is:" $vendor
echo ""