#!/bin/bash
# author     : Mike Beijerbacht
# date       : 2017/08/20
# description: Shows DNS information of a domain, by finding its SOA and performing additional 
#            : queries to the SOA
# parameter  : domain name to query

if [ $# -eq 0 ]; then
	echo ""
	echo " `basename $0` <domain name> [dns server to use]: Show DNS Information"
	echo ""
	echo "       Type of records pulled: "
	echo "       - SOA  Start of Authority, the primary name server(s)"
	echo "       - A    IPv4 addres(ses) that the domain maps to"
	echo "       - AAAA IPv6 addres(ses) that the domain maps to"
	echo "       - NS   The DNS zone to use the given authoritive name server(s)"
	echo "       - MX   Maps to the message transfer agents for this domain"
	echo "       - TXT  Carries machine readable data used by different services"
	exit 1
fi
dns=$2

echo ""
echo -e " Find info about : $1 "
if [[ ! -z "$dns" ]]; then
echo -e "      dns server : $dns"
fi
echo ""

soaRec=`nslookup -querytype=soa  -timeout=10 $1 $2| grep origin | cut -d' ' -f 3`
echo "SOA       $soaRec"

aRec=`nslookup -querytype=a      -timeout=10 $1 $soaRec | tail -2 | grep Address | cut -d' ' -f 2`
while read -r line; do echo "A         $line"; done <<< "$aRec"

# aaRec=`nslookup -querytype=a     -timeout=10 $1 $soaRec | tail -2 | grep Address | cut -d' ' -f 2`
# while read -r line; do echo "AAAA      $line"; done <<< "$aaRec"

nsRec=`nslookup -querytype=ns    -timeout-10 $1 $soaRec | grep nameserver | cut -d' ' -f 3`
while read -r line; do echo "NS        $line"; done <<< "$nsRec"

mxRec=`nslookup -querytype=mx    -timeout=10 $1 $soaRec | grep mail | cut -d = -f 2,3`
while read -r line; do echo "MX        $line"; done <<< "$mxRec"

#txtRec=`nslookup -querytype=txt  -timeout=10 $1 $soaRec | grep text | cut -d = -f 2,3,4 | tr '\n' ' '| sed 's/\" \"//g' `
txtRec=`nslookup -querytype=txt  -timeout=10 $1 $soaRec | grep text | cut -d = -f 2,3,4 | sed 's/\" \"//g' `
#echo "TXT       $txtRec"

while read -r line; do echo "TXT       $line"; done <<< "$txtRec"


