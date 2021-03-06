﻿#!/bin/bash

#Ensures Complete Setup
set -e

#Gives Root Privledges
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

#Update Packages
apt-get update
apt-get upgrade -y

#Variables
	#Dialog Sizing
	screen_size=$(stty size 2>/dev/null || echo 24 80)
	rows=$(echo "${screen_size}" | awk '{print $1}')
	columns=$(echo "${screen_size}" | awk '{print $2}')
	# Divide by two so the dialogs take up half of the screen, which looks nice.
	r=$(( rows / 2 ))
	c=$(( columns / 2 ))
	# Unless the screen is tiny
	r=$(( r < 20 ? 20 : r ))
	c=$(( c < 70 ? 70 : c ))

#Download Files
GitFiles () {

}

#Install Required Packages
InstallPackages () {
#With 'apt-get'
apt-get install unbound hostapd iproute2 iptables ip6tables openssl -y
}

#Back-up Original Files
Back-up () {

}

#Install recursive DNS Server
Unbound () {
#Define Config File Movements
IPv4 () {
	cp /etc/pi-router/configs/unbound/conf.ipv4 /etc/unbound/unbound.conf.d/pi-router.conf
}
IPv6 () {
	cp /etc/pi-router/configs/unbound/conf.ipv6 /etc/unbound/unbound.conf.d/pi-router.conf
}
Both () {
	cp /etc/pi-router/configs/unbound/conf.ipv4.ipv6 /etc/unbound/unbound.conf.d/pi-router.conf
}

#Get list of root servers and move them into place
wget -O root.hints https://www.internic.net/domain/named.root 
mv root.hints /var/lib/unbound/

#Choose Which Config To Use
whiptail --backtitle "IP" --title "IPv4 Or IPv6" --radiolist \
"Choose Protocol:" $r $c 3 \
"Both" "Both IPv4 and IPv6" ON \
"IPv4" "Only IPv4" OFF \
"IPv6" "Only IPv6" OFF 2>results

while read choice
do
case $choice in
	Both) Both;;
	IPv4) IPv4;;
	IPv6) IPv6;;
esac
done < results

}

#Custom Dynamic DNS Updater
DDNS () {
#Configuration for Duck DNS
Duck-DNS () {
#Intro to Duck DNS Setup
whiptail —-backtitle “Duck DNS” —-title “Configuring Duck DNS” —-msgbox “You will need to provide your token and domain” $r $c

#Set Token For Updating Duck DNS
TOKEN=$(whiptail —-backtitle “Token” —-title “Duck DNS Token” —-inputbox “Please enter your Duck DNS token” $r $c 3>&1 1>&2 2>&3)

#Sets Domain For Duck DNS
DOMAIN=$(whiptail —-backtitle “Domain” —-title “Duck DNS Domain” —-inputbox “Please enter your Duck DNS domain to update.” $r $c 3>&1 1>&2 2>&3)

#Save input to update script
echo “#DDNS Service Is Duck DNS

DOMAIN=$DOMAIN
TOKEN=$TOKEN” > /etc/pi-router/vars/DDNS.conf
}

#Configuration For Cloudflare DNS
Cloudflare () {
whiptail —-backtitle “Cloudflare” —-title “Configure Cloudflare DNS” —-msgbox “You will need to provide the Zone ID, DNS Record Identifier, Email, Auth Key, and Domain.” $r $c

#Sets Zone ID For Cloudflare
ZONEID=$(whiptail —-backtitle “Zone ID” —-title “Zone ID” —-inputbox “Please enter your Zone ID to update.” $r $c 3>&1 1>&2 2>&3)

#Sets DNS Record Identifier
DNSRECORDIDENTIFIER=$(whiptail —-backtitle “DNS Record” —-title “DNS Record Identifier” —-inputbox “Please enter your DNS Record Identifier to update.” $r $c 3>&1 1>&2 2>&3)

#Sets Email For Cloudflare
EMAIL=$(whiptail —-backtitle “Email” —-title “Cloudflare Email” —-inputbox “Please enter your email to update with.” $r $c 3>&1 1>&2 2>&3)

#Sets Domain For Duck DNS
AUTHKEY=$(whiptail —-backtitle “Auth Key” —-title “Cloudflare Auth Key” —-inputbox “Please enter your Auth Key to update with.” $r $c 3>&1 1>&2 2>&3)

#Sets Domain For Cloudflare
DOMAIN=$(whiptail —-backtitle “Domain” —-title “Cloudflare Domain” —-inputbox “Please enter your Cloudflare domain to update.” $r $c 3>&1 1>&2 2>&3)

#Save input to update script
echo “#DDNS Service Is Cloudflare

DOMAIN=$DOMAIN
AUTHKEY=$AUTHKEY
EMAIL=$EMAIL
ZONEID=$ZONEID
DNSRECORDIDENTIFIER=$DNSRECORDIDENDIFIER” > /etc/pi-router/vars/DDNS.conf

#Create file to update IP
cp /etc/pi-router/configs/DDNS/cloudflare.conf /etc/pi-router/DDNS.sh

#Create Cron Job

}

#Choose DDNS Provider
whiptail --backtitle "DDNS" --title "Choose Dynamic DNS Provider" --menu "Choose an option" $r $c 16 \
"Duck DNS" "Use Duck DNS as your DDNS provider" \
"Cloudflare" "Use Cloudflare as your DDNS provider" 2>results
while read choice
do
case $choice in
	Duck DNS) Duck-DNS;;
	Cloudflare) Cloudflare;;
esac
done < results

}

#Install and create CA
CA () {
whiptail --backtitle "CA" --title "Installing Certificate Authority" --msgbox "This part will install a certificate authority program and create a certificate for the router interface." ${r} ${c}
wget https://raw.githubusercontent.com/jwepdx/jwepdx.github.io/master/bashscripts/Scripts/CA
chmod +x CA
mv CA /usr/bin
CA -ca RootCA 4096
CA -sub RootCA SubCA 4096
Usage CA -c RootCA SubCA pi.router 4096 pi.hole www.pi.hole www.pi.router
whiptail --backtitle "Continue?" --title "Continue?" --yes-button "Continue" --no-button "Cancel" --yesno "The CA and certificate have been created. Do you wish to continue?" $r $c
}

#Install PiVPN
PiVPN () {
	#Create Custom version
  curl -L https://install.pivpn.io | bash
}

#Install Modified Pi-hole
Pi-hole () {
    whiptail --backtitle "Pi-hole" --title "Install Pi-hole DNS ad-blocker" --yes-button "Continue" --no-button "Cancel" --yesno "You are about to install Pi-hole, a DNS ad-blocker. The following installer has been created by Pi-hole LLC. Pi-Router is not affliiated with Pi-hole LLC" ${r} ${c}
    YN=$?
if [[ $YN == 0 ]]; then
    whiptail --backtitle "Choices" --title "Information" --msgbox "Your answers do not matter except for the Pi-hole IP address, Interface (should be br0 or if you have have vpn setup br1), and the blocking over ipv4 and ipv6 (should be both if thy are avalible)" ${r} ${c}

    #Run Pi-hole Installer
    curl -sSL https://install.pi-hole.net | bash

else
	exit 1
fi
    
}

#Bridge The Network Interfaces
Bridge () {
#Get WAN Interface
whiptail —-backtitle “WAN” —-title “Select WAN Interface —-radiolist \
“Select the interface that is connected to the internet”$r $c \
}

#Create an IPTable Firewall
IPTables () {

}

#Configure The Wireless Network
Hostapd () {
	#Gets Interfaces and finds wlan interfaces
		INTERFACES=$(iw dev | awk '$1=="Interface"{print $2}')

   #Presents prompt to ask to select interfaces for hostapd
   Choose () {
      whiptail —-backtitle “Interfaces” —-title “Choose Interfaces To Broadcast Wi-Fi” —-checklist \
“Choose Interfaces: (exclude interfaces for a mesh network backhaul.)”
   }
}

#Install Our Web Interface
Web-Interface () {

}

#Install Additional Configs That Would Have Been Overwritten
AdditionalConfigs () {

}

#Restart All Services and Reboot
RestartServices () {
#pihole

#pivpn

#hostapd

#iproute2

#iptables

}

###-Installer Starts Here-###
whiptail --backtitle "Intorduction" --title "Turn Your Raspberry Pi Into A Router" --yesno "Your Raspberry Pi will be turned into a router. Do you wish to proceed?" ${r} ${c}
YN=$?
if [[ $YN == 0 ]]; then
	GitFiles
	InstallPackages
	Back-up
	Bridge
	IPTables
	Hostapd
else
	exit 1
fi
whiptail --backtitle "Begin" --title "Select Packages To Be Installed" --checklist --separate-output \
"What Additional Packages Do You Want Install" ${r} ${c} 5 \
"Unbound" "Recursive DNS Server" ON \
"DDNS" "Update Records With Your Dynamic DNS Provider" ON \
"CA" "Create Your Own Personal Certificate Authority" ON \
"PiVPN" "Allow Access To Home Network With OpenVPN Protocols" ON \
"Pi-hole" "Caches The DNS Querys And Blocks Ads" ON 2>results
while read choice
do
case $choice in
	Unbound) Unbound;;
	DDNS) DDNS;;
	CA) CA;;
	PiVPN) PiVPN;;
	Pi-Hole) Pi-hole;;
esac
done < results
whiptail --backtitle "Finishing" --title "Almost Done" --yesno "It is know time to install the web interface and restart the component systems. Continue?" ${r} ${c}
YN=$?
if [[ $YN == 0 ]]; then
	Web-Interface
	AdditionalConfigs
	RestartServices
else
	exit 1
fi
whiptail --backtitle "Finished" --title "Rebooting"  --yes-button "Now" --no-button "Later" --yesno "Do you want to reboot now or later, some of the changes made require rebooting." ${r} ${c}
if [[ $YN == 0 ]]; then
	reboot
else
	exit 0
fi