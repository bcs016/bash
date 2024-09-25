#!/bin/bash
# Purpose     : Generate a new keypair with random password and generate pwpush url's for sharing
# Author      : Mike Beijerbacht
# requirements: openssl
#             : jq
#             : sed
#             : curl
# parameters  : 1 - basename, a value that is being used as part of the filename
#             : 2 - additional info (optional), being added to a text file
#
# output      : 1 - <value part of filename>        contains a generated password and the optional additonal info
#             : 2 - <value part of filename>.pem    generated private key
#             : 3 - <value part of filename>.pub    generated public key
#
# notes       : Default pwpush values are set to 
#             : expire_after_days = 2
#             : expire_after_views = 3

# make sure we save the temp file in the same location as the script
realScript=$(readlink "$0")
realPath=$(dirname "$realScript")
tmpFile="$realPath/testing.json"

function ShowHelp(){
    echo "Usage: $0 <basename> [additional info]"
    echo ""
    echo "  basename          : Mandatory. this part determines the filename."
    echo "  additional info   : Optional. When provided, this will be added to the file <basename>"
    echo "  -h, --help        : Show this help message"
    echo ""
    echo "            example : $0 user_mboss ticket_12340987_001"
    echo ""
    echo "       output files : user_mboss"
    echo "                    : user_mboss.pem"
    echo "                    : user_mboss.pub"
    echo ""
}
function ClearVariables(){
    unset BASENAME XTRAINFO PASSW PAYLOAD PWPUSHURL EXP_DAYS EXP_VIEWS FILENAME1 FILENAME2 FILENAME2
}
# set a trap to clear all vars used when the script is exited
trap 'ClearVariables' EXIT

# check if first parameter is -h or --help
if [[ "$1" == "-h"  || "$1" == "--help" ]]; then
    ShowHelp
    exit 0
fi
# check if basename is provided
if [ -z "$1" ]; then
    echo -e "\nERROR: Missing Basename (mandatory)\n"
    ShowHelp
    exit 1
fi

# Set the variables.
BASENAME=$1
XTRAINFO=$2
PWPUSHURL="https://pwpush.com"
EXP_DAYS=1
EXP_VIEWS=3
# generate a random password
PASSW=$(openssl rand -base64 15)
# generate files:
FILENAME1="$BASENAME"
FILENAME2="$BASENAME.pem"
FILENAME3="$BASENAME.pub"


# Display what has been provided
echo ""
echo "   Base name : $BASENAME"
if [ -n "$XTRAINFO" ]; then
    echo "  Extra Info : $XTRAINFO"
else
    echo "  Extra Info : Not provided"
fi
echo " Expire days : $EXP_DAYS"
echo "Expire views : $EXP_VIEWS"
echo ""

if [ -f $FILENAME1 ]; then rm $FILENAME1; fi
if [ -f $FILENAME2 ]; then rm $FILENAME2; fi
if [ -f $FILENAME3 ]; then rm $FILENAME3; fi

if [ -n "$XTRAINFO" ]; then echo "$XTRAINFO" > $FILENAME1; fi

echo -e "\n$PASSW\n" >> $FILENAME1

# generate file pem
printf "             : "
openssl genrsa -aes256 -passout pass:"$PASSW" -out $FILENAME2 2048
# generate file pub
openssl rsa -in $FILENAME2 -passin pass:"$PASSW" -pubout -out $FILENAME3

error=0
if [ ! -f "$FILENAME1" ]; then echo "ERROR: Missing file $FILENAME1"; error=1; fi
if [ ! -f "$FILENAME2" ]; then echo "ERROR: Missing file $FILENAME2"; error=1; fi
if [ ! -f "$FILENAME3" ]; then echo "ERROR: Missing file $FILENAME3"; error=1; fi

if [ $error == 1 ]; then
    echo "One or more files are not present. Please investigate."
    exit 1
fi

# validate the key and file
printf "             : "
openssl rsa -in "$FILENAME2" -passin pass:"$PASSW" -check -noout
if [ $? -ne 0 ]; then
    echo "Something is wrong. Password is not valid to the key"
    exit 1
fi
printf "             : "
echo "All done. Results are saved in the files '$BASENAME*'"
echo ""
printf "             : "
echo "Generating the url's for sharing..."
echo ""

# WW
PAYLOAD=$PASSW
RESPONSE=$( curl -s \
    -o "$tmpFile" \
    -X POST \
    -H "Accept: application/json" \
    -F "password[payload]=$PAYLOAD" \
    -F "password[expire_after_days]=$EXP_DAYS" \
    -F "password[expire_after_views]=$EXP_VIEWS" \
    $PWPUSHURL/p.json \
)

if [ ! -f "$tmpFile" ]; then echo "Error WW : temp file not found: $tmpFile";  exit; fi

error=$(jq ".error" "$tmpFile")
if [ "$error" != "null" ]; then
    echo "Error url WW : $(jq ".error" "$tmpFile") "
    exit 1
else 
    token=$(jq ".url_token" "$tmpFile" | sed "s/\"//g") 
    echo "     URL  ww : $PWPUSHURL/p/$token "
    rm "$tmpFile"
fi

# PEM
PAYLOAD=$(cat $FILENAME2)
RESPONSE=$( curl -s \
    -o "$tmpFile" \
    -X POST \
    -H "Accept: application/json" \
    -F "password[payload]=$PAYLOAD" \
    -F "password[expire_after_days]=$EXP_DAYS" \
    -F "password[expire_after_views]=$EXP_VIEWS" \
    $PWPUSHURL/p.json \
)

if [ ! -f "$tmpFile" ]; then echo "Error PEM : temp file not found: $tmpFile"; exit; fi
error=$(jq ".error" "$tmpFile")
if [ "$error" != "null" ]; then
    echo "Error url PEM: $( jq ".error" "$tmpFile") )"
    exit 1
else 
    token=$(jq ".url_token" "$tmpFile" | sed "s/\"//g") 
    echo "     URL pem : $PWPUSHURL/p/$token "
    rm "$tmpFile"
fi

# PUB
PAYLOAD=$(cat $FILENAME3)
RESPONSE=$( curl -s \
    -o "$tmpFile" \
    -X POST \
    -H "Accept: application/json" \
    -F "password[payload]=$PAYLOAD" \
    -F "password[expire_after_days]=$EXP_DAYS" \
    -F "password[expire_after_views]=$EXP_VIEWS" \
    $PWPUSHURL/p.json \
)

if [ ! -f "$tmpFile" ]; then echo "Error PUB : temp file not found: $tmpFile"; exit; fi
error=$(jq ".error" "$tmpFile")
if [ "$error" != "null" ]; then
    echo "Error url PUB: $( jq ".error" "$tmpFile") )"
    exit 1
else 
    token=$(jq ".url_token" "$tmpFile" | sed "s/\"//g") 
    echo "     URL pub : $PWPUSHURL/p/$token "
    rm "$tmpFile"
fi
echo ""