yum -y install git
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

wget https://raw.githubusercontent.com/adel-haouas/openvpn/master/openvpn-status -O /etc/openvpn/openvpn-status
chmod +x /etc/openvpn/openvpn-status

sed '1 s/^/management 127.0.0.1 5443\n/' /etc/openvpn/server.conf 

status /var/log/openvpn-status.log
log-append  /var/log/openvpn.log



#Enable and start the openvpn service
systemctl enable --now openvpn@server.service
