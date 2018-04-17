#!/bin/bash
i=0
while [ $i -le $1 ]
do
echo "ping:$i"
ping -c 10 -s 20000 192.168.140.129 &
i=$(($i+1))
done
