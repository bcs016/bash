#!/bin/bash
# purpose  : Return vendor name based on a given hardware mac address
# requires : curl

# encode from here: https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  ENC="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

if [ "$#" -eq 0 ]; then
	echo
	echo Find the vendor of a mac address. 
  echo
	echo "  syntax: `basename $0` <mac address>"
	echo ""
  echo "    mac address format: 00:11:22:33:44:55"
  echo "                        00-11-22-33-44-55"
  echo "                        00.11.22.33.44.55"
  echo "                        0011.2233.4455"
  echo "                        001122334455"
	exit 1
fi


OUI=${1:?'bad mac'}
rawurlencode $OUI
echo -n "MAC $OUI Vendor: "
curl https://api.macvendors.com/$ENC
#echo ""
#echo ""

