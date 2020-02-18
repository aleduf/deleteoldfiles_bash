#!/bin/bash

#delete old files
# $1 - directory
# $2 - type of files
# $3 - requirement free space in fraction

if [ -z "$1" ]; then
 echo "Usage: $0 dir_name type_files decimal"
 exit
fi

#check if folder exists
if [ ! -d "$1" ]; then
 echo "Folder not exists"
fi
#check type
if [ -z "$2" ] ; then
 echo "Type not set"
fi
#check decimal
par_fr=`bc <<< "$3*100"`
par_fr=${par_fr%.*}

if [ "$par_fr" -lt 0 ] || [ "$par_fr" -gt 100 ]; then
 echo "Value must be in the range from 0 to 100"
 exit
fi
#get free space
blocks_free=`stat -f --format=%a "$1"`
#get full space
blocks_full=`stat -f --format=%b "$1"`
#current decimal
par_ex=`bc <<< "100*$blocks_free/$blocks_full"`

systemd-cat -t DelOld echo "$par_ex"

if [ "$par_ex" -ge "$par_fr" ]; then
echo "No action"
exit
fi

until [ "$par_ex" -ge "$par_fr" ]; do
fname="$(find "$1" -name '*.'"$2" -type f -print0 | xargs -0 stat -c "%Y %N" | sort -n | head -n 1 | cut -s -d ' ' -f 2)"
echo "$fname"
rm "$i"
#get free space
blocks_free=$(stat -f --format=%a "$1")
#current decimal
par_ex=$(bc <<< "100*$blocks_free/$blocks_full")
systemd-cat -t DelOld echo "$par_ex"
done

exit
