# Setting up Transmission Jail
Create transmission jail by going to `Plugins > Available > Transmission > Install` and leave DHCP checked, do not touch anything else and press save.

# Enabling TUN for the Jail
Go to Shell (FreeNAS one and NOT the jail one) and type in the command below:

`iocage set allow_tun=1 transmission`

Reboot FreeNAS.

# Downloading and Running the Script
After reboot, go into the shell OF YOUR JAIL by clicking on the 3 dot menu next to your jail name (should be transmission) in the list.

Type the following commands:

`cp /etc/pkg/FreeBSD.conf /usr/local/etc/pkg/repos/`

`pkg install git`

`git clone https://github.com/kha0s-tickler/freenas-transmission-openvpn.git`

`cd ./freenas-transmission-openvpn`

`sh freenas-transmission-openvpn.sh`

# Troubleshooting
If the script ran fine with no errors, but transmission torrents aren't downloading, and `wget http://ipinfo.io/IP -qO -` does not return an ip address, pihole may be interfereing with it if you have one set up. In which case, you need to disable pihole (or whitelist ipinfo.io) and start the entire process from step 1 again.
