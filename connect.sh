#!/bin/sh

SMTP="smtp.xyz.com"
# FROM="<email sender address>"
FROMNAME="<no-reply@xyz.com>"
TO="<someone@xyz.com>"

#FROM="<your SMTP address>"
#AUTH="<your gmail username>"
#PASS="<your gmail password>"
#FROMNAME="<your router name>"
#TO="<recipient email address>"

time=$(echo $(date +"%c"))
tmpFILE=$(mktemp)

echo "Subject: OpenVPN CONNECT" >$tmpFILE
echo "Content-Type: text/html" >>$tmpFILE
echo "From: $FROMNAME<$FROM>" >>$tmpFILE
echo "Date: `date -R`" >>$tmpFILE
echo "" >>$tmpFILE
echo "Client has connected to OpenVPN:" >>$tmpFILE
echo "" >>$tmpFILE

echo "  Connected Since: $time" >>$tmpFILE
echo "  Real Address: $untrusted_ip" >>$tmpFILE
echo "  Virtual Address: $ifconfig_pool_remote_ip" >>$tmpFILE
echo "  Common Name: $common_name" >>$tmpFILE

echo "" >>$tmpFILE
echo "---" >>$tmpFILE
echo "Your friendly OpenVPN server." >>$tmpFILE
echo "" >>$tmpFILE

mailx -s "OpenVPN CONNECT" -r $FROMNAME -v -S smtp=$SMTP  $TO < $tmpFILE
rm -f $tmpFILE
exit 0
