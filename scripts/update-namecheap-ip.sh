#!/bin/sh

curl -s -o /dev/null "https://dynamicdns.park-your-domain.com/update?host=@&domain=erichaag.io&password=$ERICHAAG_IO_PASSWORD&ip=$1"
curl -s -o /dev/null "https://dynamicdns.park-your-domain.com/update?host=*&domain=erichaag.io&password=$ERICHAAG_IO_PASSWORD&ip=$1"
