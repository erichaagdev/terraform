#!/bin/sh

curl -s -o /dev/null "https://dynamicdns.park-your-domain.com/update?host=@&domain=$1&ip=$2&password=$3"
curl -s -o /dev/null "https://dynamicdns.park-your-domain.com/update?host=*&domain=$1&ip=$2&password=$3"
