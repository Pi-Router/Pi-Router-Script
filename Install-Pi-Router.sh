#!/bin/bash

#Ensures Complete Setup
set -e

#Gives Root Privledges
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

#Variables


#Download Files
GitFiles () {

}

#Install Required Packages
InstallPackages () {
#With 'apt-get'
apt-get install unbound hostapd bridge-utils iptables openssl
}

#Back-up Original Files
Back-up () {

}

#Install recursive DNS Server
Unbound () {

}

#Bridge The Network Interfaces
Bridge () {

}

#Create an IPTable Firewall
IPTables () {

}

#Configure The Wireless Adapters to 
Hostapd () {

}

#Custom Dynamic DNS Updater
DDNS () {

}

#Install and create CA
CA () {
whiptail --backtitle "CA" --title "Installing Certificate Authority" --msgbox "This part will install a certificate authority program and create a certificate for the router interface." 8 78
wget https://raw.githubusercontent.com/jwepdx/jwepdx.github.io/master/bashscripts/Scripts/CA
chmod +x CA
mv CA /usr/bin
CA -ca RootCA 4096
CA -sub RootCA SubCA 4096
Usage CA -c RootCA SubCA pi.router 4096 pi.hole www.pi.hole www.pi.router
}

#Install PiVPN
PiVPN () {
  
}

#Install Modified Pi-hole
Pi-hole () {
    whiptail --backtitle "Pi-hole" --title "Install Pi-hole DNS ad-blocker" --msgbox "You are about to install Pi-hole, a DNS ad-blocker. The following installer has been created by Pi-hole LLC. Pi-Router is not affliiated with Pi-hole LLC" 8 78
    whiptail --backtitle "Choices" --title "Information" --msgbox "Your answers do not matter except for the IP address, Interface (should be br0), and the blocking over ipv4 and ipv6 (should be both if thy are avalible)" 8 78

    #Run Pi-hole Installer
    curl -sSL https://install.pi-hole.net | bash

    #Set To Use FTLDNS Beta
    echo "FTLDNS" | sudo tee /etc/pihole/ftlbranch
    pihole checkout core FTLDNS
    pihole checkout web FTLDNS

}

#Install Web Interface
Web-Interface () {

}

#Restart All Services and Reboot
Restart () {

}

###-Installer Starts Here-###
whiptail --title "Select Packages To Be Installed" --checklist \
"What Packages Do You Want Install" 20 78 4 \
"Unbound" "Recursive DNS Server" ON \
"DDNS" "Update Records With Your Dynamic DNS Provider" ON \
"CA" "Create Your" ON \
"PiVPN" "Allow mounting of local devices" ON \
"Pi-hole" "Allow mounting of remote devices" ON
