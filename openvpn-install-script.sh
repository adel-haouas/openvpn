##Centos 7

yum -y install git zip
mkdir -pv /root/openvpn-clients/
cd /root
git clone https://github.com/angristan/openvpn-install.git

cd openvpn-install/
sed -i "s/setenv opt block-outside-dns/#setenv opt block-outside-dns/g" openvpn-install.sh

SHARK=$(ip route get 8.8.8.8 | awk 'NR==1 {print $(NF-2)}')
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING  -o $SHARK -j MASQUERADE
firewall-cmd --reload

firewall-cmd --add-service=https --permanent
firewall-cmd --reload 

##begin the openvpn installation
./openvpn-install.sh

wget https://raw.githubusercontent.com/adel-haouas/openvpn/master/openvpn-status -O /etc/openvpn/openvpn-status
chmod +x /etc/openvpn/openvpn-status

sed -i '1 s/^/management 127.0.0.1 5443\n/' /etc/openvpn/server.conf 
sed -i "s/^status .*$/status \/var\/log\/openvpn-status.log/g" /etc/openvpn/server.conf
echo "log-append /var/log/openvpn.log" >> /etc/openvpn/server.conf


#Permit access to the openvpn server from its subnet
GLOBAL_IP=`curl -4 icanhazip.com 2>/dev/null`
echo "push \"route $GLOBAL_IP 255.255.255.255 net_gateway\"" >> /etc/openvpn/server.conf

#Enable and start the openvpn service
systemctl enable openvpn@server.service
systemctl restart openvpn@server.service


##centos8
##to resolve the error "/usr/bin/env: ‘python’: No such file or directory"
yum install python2 -y
alternatives --set python /usr/bin/python2
