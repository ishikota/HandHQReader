#!/bin/sh

fname=data_url.txt
while read line ; do
  wget -nc http://web.archive.org/web/${line} -P ../../raw_data
done < ${fname}
