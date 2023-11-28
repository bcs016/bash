#/bin/bash
# purpose : enable or disable power on after opening lid
# date    : 28-11-2023
# requires: macOS

if [ $(uname -s) != 'Darwin' ]; then
    # Not macOS
    echo ""
    echo "This script is meant for a macOS system."
    echo ""
    exit 2
fi

if [ $# -eq 0 ]; then
    # no input provided
    base=`basename $0`
    echo ""
    echo "${base##*/} <status> | <enable> | <disable>"
    echo ""
    echo "Must have root privileges to be able to run"
    echo ""
    exit 1
fi
argument=$1

if [ "${EUID:-$(id -u)}" -ne 0  ]; then
    echo ""
    echo "This script must be run as root, switching to root..."
    echo ""
    sudo $0 $1
    exit 0
fi

case $argument in
    status)
        echo "Status check"
        sudo nvram auto-boot
        ;;
    enable)
        echo "Enable power on lid"
        sudo nvram auto-boot=true
        ;;
    disable)
        echo "Disable power on Lid"
        sudo nvram auto-boot=false
        ;;
    *)
        echo "Invalid option"
        exit 99;;
esac


