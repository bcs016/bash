#!/bin/bash
# purpose  : Return vendor name based on a given hardware mac address
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

echo ""

if [[ "$result" == *"{"* ]]; then 
    vendor=$(echo $result | jq '. [] | .detail')
    echo "Vendor is:" $vendor
else 
    echo Vendor is: $result 
fi

echo ""
