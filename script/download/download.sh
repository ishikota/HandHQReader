#!/bin/sh

BASEDIR=$(dirname "$0")
fname=$BASEDIR$'/data_url.txt'
while read line ; do
  wget -nc http://web.archive.org/web/${line} -P $BASEDIR$'/../../raw_data'
done < ${fname}
