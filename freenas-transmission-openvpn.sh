#!/bin/bash
printf "Starting OpenVPN setup for Transmission...\n\n"
service transmission stop
printf "Enabling FreeBSD repo...\n\n"
sed -i '' -e 's/no/yes/' /usr/local/etc/pkg/repos/FreeBSD.conf
printf "Updating repos...\n\n"
pkg update
pkg upgrade
printf "Installing packages...\n\n"
pkg install -y bash openvpn unzip curl wget nano
printf "\nAdding openvpn and firewall lines to /etc/rc.conf\n\n"
echo '
openvpn_enable="YES"
openvpn_configfile="/usr/local/etc/openvpn/openvpn.conf"
firewall_enable="YES"
firewall_script="/etc/ipfw.rules"' >> /etc/rc.conf
sed -i '' -e 's/\/usr\/local\/etc\/transmission\/home\/Downloads/\/media/' /etc/rc.conf
printf "Installing OpenVPN configs...\n\n"
cd ./config
wget https://support.goldenfrog.com/hc/article_attachments/360008728172/GF_OpenVPN_10142016.zip
unzip GF_OpenVPN_10142016.zip
rm GF_OpenVPN_10142016.zip
mkdir /usr/local/etc/openvpn/
printf "\nUsing USA - Los Angeles server!\n\n"
cp ./GF_OpenVPN_10142016/OpenVPN256/USA\ -\ Los\ Angeles.ovpn /usr/local/etc/openvpn/openvpn.conf
#wget https://www.privateinternetaccess.com/openvpn/openvpn.zip --no-check-certificate
#mkdir PIA 
#unzip openvpn.zip -d PIA/ 
#cd PIA/ || exit 
#printf "\nUsing UK Southampton server!\n\n"
#cp UK\ Southampton.ovpn .. 
#cd .. 
#mv UK\ Southampton.ovpn openvpn.conf
echo 'Enter username: '
read -r username
echo 'Enter password: '
read -r password
printf "\nSaving credentials in plaintext...\n\n"
printf "%s\n%s" "$username" "$password" > pass.txt
sed -i '' -e 's/auth-user-pass/auth-user-pass \/usr\/local\/etc\/openvpn\/pass.txt/' openvpn.conf
echo "Enter local ip of this jail: "
read -r ipaddress
export ipaddress
printf "Adding firewall rules for openvpn...\n\n"
echo "
#!/bin/bash
ipfw -q -f flush
ipfw -q add 00001 allow all from any to any via lo0
ipfw -q add 00010 allow all from any to any via tun0
ipfw -q add 00101 allow all from me to ${ipaddress}/24 uid transmission
ipfw -q add 00102 allow all from ${ipaddress}/24 to me uid transmission
ipfw -q add 00103 deny all from any to any uid transmission" > /etc/ipfw.rules
service ipfw start
ipfw list
printf "Finishing up...\n\n"
service openvpn start
sleep 10
service openvpn status
echo "Set-up finished! Check IP below for confirmation and restart the jail!"
wget http://ipinfo.io/IP -qO -
