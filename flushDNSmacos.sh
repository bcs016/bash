#/bin/bash
# purpose : flush local DNS. 
# requires: macOS version 11.x or higher

sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder