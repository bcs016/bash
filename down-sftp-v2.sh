#!/bin/bash
# Purpose : Download files from a server 
# Change settings to match your environment


datestring=$(date +'%Y-%m-%d')
sourcepath='/some/path/with/files/'

usage() {
    echo ""
    echo "Usage: $0 [-h] | [-d <date string>] [-p <source path>]"
    echo "Options:"
    echo "   -d <date string>: Date string in the format YYYY-MM-DD (optional)"
    echo "   -p <source path>: Path in FTP site to download files from (optional)"
    exit 1
}

while getopts ":d:p:h" opt; do
    case ${opt} in
        d)
            datestring=$OPTARG
            ;;
        p)
            sourcepath=$OPTARG
            ;;
        h)
            #echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -${OPTARG} requires an argument" >&2
            #usage
            exit 1
            ;;
        ?)
            echo "Invalid option: - ${OPTARG}" >&2
            #usage
            exit 1
            ;;
    esac

done


echo "date  : $datestring"
echo "path  : $sourcepath"

REMOTE_DIR='$sourcepath'
TARGET_DIR='/Users/'

if [ ! -d "$TARGET_DIR" ]; then
    echo "Local DIR doesnt exist: $TARGET_DIR"
    exit
fi

# === Change sftp server information  ====
FTP_SERVER=localhost
SFTP_USER=testuser
SFTP_PASS=testuser01
# ========================================

CURRENT_DIR=$(pwd)

cd $TARGET_DIR
echo ""
echo "Connecting..."

sftp $SFT_SERVER <<END_SCRIPT
quote USER $SFTP_USER
quote PASS $SFTP_PASS

ls $REMOTE_DIR
if [ $? -ne 0 ]; then
    echo "Remote directory not found: $REMOTE_DIR"
    bye
fi
mget $REMOTE_DIR/$datestring.zip

cd $REMOTE_DIR
ls -l

bye
END_SCRIPT

cd $CURRENT_DIR