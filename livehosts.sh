#!/bin/bash
# purpose: present responsive ip's in a given network

if [  "$1" == "" ]; then
    echo ""
    echo "   Syntax : $(basename $0) <ip network/mask>"
    echo ""
    exit 1
fi

nmap $1 -n -sP | grep report | awk '{print $5}'
