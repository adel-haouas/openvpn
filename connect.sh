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

message=$(echo "<b>Connected Since:</b> $time<br><b>Real Address:</b> \
$untrusted_ip<br><b>Virtual Address:</b> \
$ifconfig_pool_remote_ip<br><b>Common \
Name:</b> $common_name<br><br>")

echo "Subject: OpenVPN CONNECT" >$tmpFILE
echo "Content-Type: text/html" >>$tmpFILE
echo "From: $FROMNAME<$FROM>" >>$tmpFILE
echo "Date: `date -R`" >>$tmpFILE
echo "" >>$tmpFILE
echo "Client has connected to <b>OpenVPN</b>:<br>" >>$tmpFILE
echo "" >>$tmpFILE
echo "<br>$message" >>$tmpFILE
echo "" >>$tmpFILE
echo "---<br>" >>$tmpFILE
echo "Your friendly OpenVPN server." >>$tmpFILE
echo "<br>" >>$tmpFILE

mailx -s "OpenVPN CONNECT" -r $FROMNAME -v -S smtp=$SMTP  $TO < $tmpFILE

rm -f $tmpFILE
exit 0