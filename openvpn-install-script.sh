##Centos 7

yum -y install git zip
mkdir -pv /root/openvpn-clients/
cd /root
git clone https://github.com/angristan/openvpn-install.git

cd openvpn-install/
sed -i "s/setenv opt block-outside-dns/#setenv opt block-outside-dns/g" openvpn-install.sh
sed -i "s/ip.seeip.org/icanhazip.com/g" openvpn-install.sh

##replace subnet 10.8.0/24 by 10.8.xyz/24 where xyz is the random number between 0 and 255
RND_NUMBER=$(shuf -i0-255 -n1);sed -i "s/10.8.0/10.8.$RND_NUMBER/g" openvpn-install.sh

#Centos
SHARK=$(ip route get 8.8.8.8 | awk 'NR==1 {print $(NF-2)}')

#Debian/ubuntu
SHARK=$(ip route get 8.8.8.8 | awk 'NR==1 {print $(NF-4)}')
firewall-cmd --permanent --add-masquerade 2>/dev/null
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING  -o $SHARK -j MASQUERADE 2>/dev/null

firewall-cmd --add-service=https --permanent 2>/dev/null
firewall-cmd --reload 

##to protect user profile by password
#edit openvpn-install.sh file and add theses lines to the end of newClient() function
        PaSS=$(openssl rand -base64 12)
        echo $(date)" ## "$CLIENT" : "$PaSS >> /var/log/ovpn.bin
        zip -P $PaSS /root/openvpn-clients/$CLIENT.ovpn.zip /root/$CLIENT.ovpn >/dev/null
        rm -f /root/$CLIENT.ovpn

        echo ""
        echo "The configuration file has been written to /root/openvpn-clients/$CLIENT.ovpn.zip"
        echo "Download the .ovpn.zip file and import it in your OpenVPN client."
        echo "File is password protected"

##begin the openvpn installation
./openvpn-install.sh

wget https://raw.githubusercontent.com/adel-haouas/openvpn/master/openvpn-status -O /etc/openvpn/openvpn-status
chmod +x /etc/openvpn/openvpn-status

sed -i '1 s/^/management 127.0.0.1 5443\n/' /etc/openvpn/server.conf 
sed -i "s/^status .*$/status \/var\/log\/openvpn-status.log/g" /etc/openvpn/server.conf
echo "log-append /var/log/openvpn.log" >> /etc/openvpn/server.conf
rm -rfv /var/log/openvpn

#Permit access to the openvpn server from its subnet
GLOBAL_IP=`curl -4 icanhazip.com 2>/dev/null`
echo "push \"route $GLOBAL_IP 255.255.255.255 net_gateway\"" >> /etc/openvpn/server.conf

#Disable sending all IP network traffic originating on client machines to pass through the OpenVPN server
sed -i 's/^push "redirect-gateway def1 bypass-dhcp"/#push "redirect-gateway def1 bypass-dhcp"/g' /etc/openvpn/server.conf 

#Enable and start the openvpn service
systemctl enable --now openvpn-server@server.service 
systemctl restart openvpn-server@server.service 

#systemctl enable --now openvpn@server.service
#systemctl restart openvpn@server.service

##centos8
##to resolve the error "/usr/bin/env: ‘python’: No such file or directory"
yum install python2 -y
alternatives --set python /usr/bin/python2
