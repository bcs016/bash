#!/bin/bash
# Purpose : Random excuse generator
# Requires: excuses.txt needs to be in same folder as this script

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET=$(readlink "$SOURCE")
  if [[ $TARGET == /* ]]; then
    #echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE=$TARGET
  else
    DIR=$( dirname "$SOURCE" )
    #echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE=$DIR/$TARGET # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done

DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
RDIR=$( dirname "$SOURCE" )

#echo "RDIR = $RDIR"
#echo " DIR = $DIR"

# get a random line number
line=$(($RANDOM%`grep -c '$' $RDIR/excuses.txt`))

#cat << !
#=== The BOFH-style Excuse Server --- Feel The Power!
#=== By Jeff Ballard <ballard@cs.wisc.edu>
#=== See http://www.cs.wisc.edu/~ballard/bofh/ for more info.
#!

cat -n $RDIR/excuses.txt|while read a b
do
    [ "$a" = "$line" ] && { echo "Your excuse is: $b"; break; }
done
